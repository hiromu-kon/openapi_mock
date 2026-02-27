import 'dart:convert';
import 'dart:io';

import 'openapi_mock_core.dart';

class OpenApiMockServer {
  OpenApiMockServer._({
    required HttpServer server,
    required OpenApiMock mock,
  })  : _server = server,
        _mock = mock;

  final HttpServer _server;
  final OpenApiMock _mock;

  Uri get baseUri => Uri(
        scheme: 'http',
        host: _server.address.address,
        port: _server.port,
      );

  int get port => _server.port;

  static Future<OpenApiMockServer> start({
    required OpenApiMock mock,
    String host = '127.0.0.1',
    int port = 0,
  }) async {
    final server = await HttpServer.bind(host, port);
    final instance = OpenApiMockServer._(server: server, mock: mock);
    instance._serve();
    return instance;
  }

  static Future<OpenApiMockServer> fromFile({
    required String path,
    String host = '127.0.0.1',
    int port = 0,
  }) async {
    final mock = await OpenApiMock.fromFile(path);
    return start(mock: mock, host: host, port: port);
  }

  Future<void> close({bool force = false}) => _server.close(force: force);

  void _serve() {
    _server.listen((request) async {
      final body = await _readRequestBody(request);
      final response = _mock.resolve(
        MockRequest(
          method: request.method,
          path: request.uri.path,
          query: request.uri.queryParameters,
          headers: _flattenHeaders(request.headers),
          body: body,
        ),
      );
      request.response.statusCode = response.statusCode;
      response.headers.forEach(request.response.headers.set);
      if (response.body != null) {
        if (response.body is String) {
          request.response.write(response.body);
        } else {
          request.response.write(jsonEncode(response.body));
          if (request.response.headers.value('content-type') == null) {
            request.response.headers.set('content-type', 'application/json');
          }
        }
      }
      await request.response.close();
    });
  }

  Map<String, String> _flattenHeaders(HttpHeaders headers) {
    final map = <String, String>{};
    headers.forEach((name, values) {
      map[name] = values.join(', ');
    });
    return map;
  }

  Future<Object?> _readRequestBody(HttpRequest request) async {
    final content = await utf8.decoder.bind(request).join();
    if (content.isEmpty) {
      return null;
    }

    final contentType = request.headers.contentType?.mimeType.toLowerCase();
    if (contentType == 'application/json') {
      try {
        return jsonDecode(content);
      } on FormatException {
        return content;
      }
    }
    return content;
  }
}
