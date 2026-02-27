# openapi_mock_http

HTTP adapter package for `openapi_mock`.

```dart
import 'package:http/http.dart' as http;
import 'package:openapi_mock/openapi_mock.dart';
import 'package:openapi_mock_http/openapi_mock_http.dart';

final mock = await OpenApiMock.fromFile('openapi.yaml');
final client = OpenApiMockHttpClient(
  mock: mock,
  fallback: http.Client(),
  mode: MockMode.mixed,
);
```
