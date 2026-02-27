import 'package:dio/dio.dart';

import 'openapi_mock_core.dart';
import 'openapi_mock_mode.dart';

class OpenApiMockDioInterceptor extends Interceptor {
  OpenApiMockDioInterceptor({
    required this.mock,
    this.mode = MockMode.mixed,
  });

  final OpenApiMock mock;
  final MockMode mode;

  static Future<OpenApiMockDioInterceptor> fromFile(
    String path, {
    MockMode mode = MockMode.mixed,
  }) async {
    final mock = await OpenApiMock.fromFile(path);
    return OpenApiMockDioInterceptor(mock: mock, mode: mode);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (mode == MockMode.passthrough) {
      handler.next(options);
      return;
    }

    final request = MockRequest(
      method: options.method,
      path: options.uri.path,
      query: options.queryParameters.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
      headers: options.headers.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
      body: options.data,
    );

    final mockResponse = mode == MockMode.mixed
        ? mock.tryResolve(request)
        : mock.resolve(request);

    if (mockResponse == null) {
      handler.next(options);
      return;
    }

    handler.resolve(
      Response<dynamic>(
        requestOptions: options,
        statusCode: mockResponse.statusCode,
        data: mockResponse.body,
        headers: Headers.fromMap(
          mockResponse.headers.map(
            (key, value) => MapEntry(key, <String>[value]),
          ),
        ),
      ),
    );
  }
}
