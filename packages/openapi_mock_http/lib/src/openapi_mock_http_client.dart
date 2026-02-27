import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:openapi_mock/openapi_mock.dart';

class OpenApiMockHttpClient extends http.BaseClient {
  OpenApiMockHttpClient({
    required this.mock,
    required this.fallback,
    this.mode = MockMode.mixed,
  });

  final OpenApiMock mock;
  final http.Client fallback;
  final MockMode mode;

  static Future<OpenApiMockHttpClient> fromFile({
    required String path,
    required http.Client fallback,
    MockMode mode = MockMode.mixed,
  }) async {
    final mock = await OpenApiMock.fromFile(path);
    return OpenApiMockHttpClient(mock: mock, fallback: fallback, mode: mode);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (mode == MockMode.passthrough) {
      return fallback.send(request);
    }

    final mockRequest = MockRequest(
      method: request.method,
      path: request.url.path,
      query: request.url.queryParameters,
      headers: request.headers,
    );

    final mockResponse = mode == MockMode.mixed
        ? mock.tryResolve(mockRequest)
        : mock.resolve(mockRequest);

    if (mockResponse == null) {
      return fallback.send(request);
    }

    final bodyText = _toTextBody(mockResponse.body);
    final bodyBytes = Uint8List.fromList(utf8.encode(bodyText));

    return http.StreamedResponse(
      Stream<List<int>>.fromIterable(<List<int>>[bodyBytes]),
      mockResponse.statusCode,
      headers: <String, String>{
        ...mockResponse.headers,
        if (!mockResponse.headers.containsKey('content-type'))
          'content-type': 'application/json',
      },
      request: request,
      contentLength: bodyBytes.length,
    );
  }

  @override
  void close() {
    fallback.close();
  }

  String _toTextBody(Object? body) {
    if (body == null) {
      return '';
    }
    if (body is String) {
      return body;
    }
    return jsonEncode(body);
  }
}
