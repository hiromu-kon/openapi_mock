import 'dart:convert';

import 'package:yaml/yaml.dart';

import 'file_loader.dart';

/// An HTTP-like request abstraction for OpenAPI mock resolution.
class MockRequest {
  MockRequest({
    required this.method,
    required this.path,
    this.query = const <String, String>{},
    this.headers = const <String, String>{},
    this.body,
  });

  final String method;
  final String path;
  final Map<String, String> query;
  final Map<String, String> headers;
  final Object? body;
}

/// An HTTP-like response abstraction returned by the mock engine.
class MockResponse {
  MockResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
  });

  final int statusCode;
  final Map<String, String> headers;
  final Object? body;
}

/// Resolves responses from an OpenAPI document.
///
/// Current MVP supports:
/// - `method + path` matching (`/users/{id}` style)
/// - response selection from `x-mock-response`, `examples`, `example`
/// - fallback to first available schema when example does not exist
class OpenApiMock {
  OpenApiMock._(this._spec);

  final Map<String, dynamic> _spec;

  factory OpenApiMock.fromMap(Map<String, dynamic> spec) => OpenApiMock._(spec);

  factory OpenApiMock.fromJsonString(String openApiJson) {
    final decoded = jsonDecode(openApiJson);
    if (decoded is! Map) {
      throw FormatException('OpenAPI root must be a JSON object.');
    }
    return OpenApiMock._(_toPlainMap(decoded));
  }

  factory OpenApiMock.fromYamlString(String openApiYaml) {
    final decoded = loadYaml(openApiYaml);
    if (decoded is! Map) {
      throw FormatException('OpenAPI root must be a YAML map.');
    }
    return OpenApiMock._(_toPlainMap(decoded));
  }

  /// Detects JSON first, then falls back to YAML.
  factory OpenApiMock.fromString(String openApiDocument) {
    try {
      return OpenApiMock.fromJsonString(openApiDocument);
    } on FormatException {
      return OpenApiMock.fromYamlString(openApiDocument);
    }
  }

  /// Loads an OpenAPI document from file and parses JSON/YAML automatically.
  static Future<OpenApiMock> fromFile(String path) async {
    final raw = await readTextFile(path);
    return OpenApiMock.fromString(raw);
  }

  /// Loads an OpenAPI document from URI and parses JSON/YAML automatically.
  ///
  /// Supported schemes on dart:io platforms: `file`, `http`, `https`.
  static Future<OpenApiMock> fromUri(Uri uri) async {
    final raw = await readTextUri(uri);
    return OpenApiMock.fromString(raw);
  }

  MockResponse? tryResolve(MockRequest request) {
    final normalizedMethod = request.method.toLowerCase();
    final paths = _spec['paths'];
    if (paths is! Map) {
      return _error(500, 'Invalid OpenAPI: "paths" is missing.');
    }

    final match = _findPathMatch(request.path, paths);
    if (match == null) {
      return null;
    }

    final operation = match.pathItem[normalizedMethod];
    if (operation is! Map) {
      return null;
    }

    // Allow explicit override from vendor extension.
    final extensionResponse = operation['x-mock-response'];
    if (extensionResponse is Map<String, dynamic>) {
      return _fromXMockResponse(extensionResponse);
    }

    final responses = operation['responses'];
    if (responses is! Map) {
      return _error(500, 'Operation has no valid "responses" object.');
    }

    final statusCode = _selectStatusCode(responses);
    final selectedResponse = responses['$statusCode'] ?? responses['default'];
    if (selectedResponse is! Map) {
      return _error(500, 'No valid response object found for selected status.');
    }

    final content = selectedResponse['content'];
    if (content is! Map || content.isEmpty) {
      return MockResponse(
        statusCode: statusCode,
        headers: <String, String>{},
        body: null,
      );
    }

    final mediaTypeEntry = _pickMediaType(content);
    final mediaType = mediaTypeEntry.$1;
    final mediaSchema = mediaTypeEntry.$2;

    final body = _pickExample(mediaSchema) ?? mediaSchema['schema'];
    return MockResponse(
      statusCode: statusCode,
      headers: <String, String>{'content-type': mediaType},
      body: body,
    );
  }

  MockResponse resolve(MockRequest request) {
    final resolved = tryResolve(request);
    if (resolved != null) {
      return resolved;
    }
    return _error(
      404,
      'No operation matched for ${request.method.toUpperCase()} ${request.path}.',
    );
  }

  _PathMatch? _findPathMatch(String requestPath, Map paths) {
    final requestSegments = _normalizePath(requestPath);
    for (final entry in paths.entries) {
      final candidate = entry.key;
      if (candidate is! String || entry.value is! Map<String, dynamic>) {
        continue;
      }
      final templateSegments = _normalizePath(candidate);
      if (_segmentsMatch(requestSegments, templateSegments)) {
        return _PathMatch(entry.value as Map<String, dynamic>);
      }
    }
    return null;
  }

  List<String> _normalizePath(String path) => path
      .split('?')
      .first
      .split('/')
      .where((segment) => segment.isNotEmpty)
      .toList(growable: false);

  bool _segmentsMatch(List<String> request, List<String> template) {
    if (request.length != template.length) {
      return false;
    }
    for (var i = 0; i < request.length; i++) {
      final candidate = template[i];
      if (candidate.startsWith('{') && candidate.endsWith('}')) {
        continue;
      }
      if (candidate != request[i]) {
        return false;
      }
    }
    return true;
  }

  MockResponse _fromXMockResponse(Map<String, dynamic> raw) {
    final status = raw['statusCode'];
    final headers = raw['headers'];
    return MockResponse(
      statusCode: status is int ? status : 200,
      headers: headers is Map
          ? headers.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : <String, String>{},
      body: raw['body'],
    );
  }

  int _selectStatusCode(Map responses) {
    final keys =
        responses.keys.map((key) => key.toString()).toList(growable: false);
    final sorted = keys..sort();
    for (final key in sorted) {
      final code = int.tryParse(key);
      if (code != null && code >= 200 && code <= 299) {
        return code;
      }
    }
    for (final key in sorted) {
      final code = int.tryParse(key);
      if (code != null) {
        return code;
      }
    }
    return 200;
  }

  (String, Map<String, dynamic>) _pickMediaType(Map content) {
    // Prefer JSON, then YAML, then first declared media type.
    final preferred = <String>{
      'application/json',
      'application/yaml',
      'text/yaml',
    };
    final jsonEntry = content.entries.firstWhere(
      (entry) => preferred.contains(entry.key.toString().toLowerCase()),
      orElse: () => content.entries.first,
    );
    final mediaType = jsonEntry.key.toString();
    final mediaSchema = jsonEntry.value;
    if (mediaSchema is Map<String, dynamic>) {
      return (mediaType, mediaSchema);
    }
    return (mediaType, <String, dynamic>{});
  }

  Object? _pickExample(Map<String, dynamic> mediaSchema) {
    final examples = mediaSchema['examples'];
    if (examples is Map && examples.isNotEmpty) {
      final firstExample = examples.values.first;
      if (firstExample is Map && firstExample.containsKey('value')) {
        return firstExample['value'];
      }
      return firstExample;
    }

    if (mediaSchema.containsKey('example')) {
      return mediaSchema['example'];
    }

    return null;
  }

  MockResponse _error(int statusCode, String message) => MockResponse(
        statusCode: statusCode,
        headers: const <String, String>{'content-type': 'application/json'},
        body: <String, Object?>{'error': message},
      );

  static Map<String, dynamic> _toPlainMap(Map source) => source.map(
        (key, value) => MapEntry(key.toString(), _toPlainObject(value)),
      );

  static List<dynamic> _toPlainList(List source) =>
      source.map(_toPlainObject).toList(growable: false);

  static dynamic _toPlainObject(Object? value) {
    if (value is Map) {
      return _toPlainMap(value);
    }
    if (value is List) {
      return _toPlainList(value);
    }
    return value;
  }
}

class _PathMatch {
  _PathMatch(this.pathItem);

  final Map<String, dynamic> pathItem;
}
