# openapi_mock

Core OpenAPI-driven mock engine for Dart and Flutter.

## What this package includes

- OpenAPI parsing from JSON/YAML
- Request resolution by method + path (`/users/{id}`)
- Response extraction from `x-mock-response`, `examples`, `example`
- Convenience loaders: `fromFile`, `fromUri`

## Core usage

```dart
import 'dart:convert';
import 'package:openapi_mock/openapi_mock.dart';

Future<void> main() async {
  final mock = await OpenApiMock.fromFile('example/openapi.yaml');
  final response = mock.resolve(
    MockRequest(method: 'GET', path: '/users/42'),
  );

  print(response.statusCode);
  print(jsonEncode(response.body));
}
```

## Adapter packages

- `openapi_mock_http`
- `openapi_mock_dio`
- `openapi_mock_server`

## CLI package

- `openapi_mock_cli`
