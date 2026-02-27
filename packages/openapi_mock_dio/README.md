# openapi_mock_dio

Dio interceptor adapter package for `openapi_mock`.

```dart
import 'package:dio/dio.dart';
import 'package:openapi_mock_dio/openapi_mock_dio.dart';

final dio = Dio();
dio.interceptors.add(
  await OpenApiMockDioInterceptor.fromFile('openapi.yaml'),
);
```
