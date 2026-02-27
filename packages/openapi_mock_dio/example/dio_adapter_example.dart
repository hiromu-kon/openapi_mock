import 'package:dio/dio.dart';
import 'package:openapi_mock_dio/openapi_mock_dio.dart';

Future<void> main() async {
  final dio = Dio(
    BaseOptions(baseUrl: 'https://api.example.com'),
  );

  dio.interceptors.add(
    await OpenApiMockDioInterceptor.fromFile(
      'example/openapi.yaml',
    ),
  );

  final response = await dio.get('/users/42');
  print('status=${response.statusCode}');
  print('data=${response.data}');
}
