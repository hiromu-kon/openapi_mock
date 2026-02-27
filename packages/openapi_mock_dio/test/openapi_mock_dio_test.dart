import 'package:openapi_mock_dio/openapi_mock_dio.dart';
import 'package:test/test.dart';

void main() {
  test('can create interceptor', () {
    final mock = OpenApiMock.fromMap(<String, dynamic>{
      'openapi': '3.0.0',
      'paths': <String, Object?>{},
    });

    final interceptor = OpenApiMockDioInterceptor(mock: mock);
    expect(interceptor.mode, MockMode.mixed);
  });
}
