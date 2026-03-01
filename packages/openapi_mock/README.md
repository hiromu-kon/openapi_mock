# openapi_mock

[![pub package](https://img.shields.io/pub/v/openapi_mock.svg)](https://pub.dev/packages/openapi_mock)

Core OpenAPI-driven mock engine for Dart and Flutter.

## Features

- OpenAPI parsing from JSON and YAML
- Request resolution by method and path such as `/users/{id}`
- Response extraction from `x-mock-response`, `examples`, and `example`
- Convenience loaders: `fromFile` and `fromUri`

## Installation

```yaml
dependencies:
  openapi_mock: ^0.0.1
```

## Usage

```dart
import 'dart:convert';
import 'package:openapi_mock/openapi_mock.dart';

Future<void> main() async {
  final mock = await OpenApiMock.fromFile('openapi.yaml');
  final response = mock.resolve(
    MockRequest(method: 'GET', path: '/users/42'),
  );

  print(response.statusCode);
  print(jsonEncode(response.body));
}
```

## Load from file or URI

```dart
final fromFile = await OpenApiMock.fromFile('openapi.yaml');
final fromUri = await OpenApiMock.fromUri(
  Uri.parse('https://example.com/openapi.yaml'),
);
```

## Related packages

- [`openapi_mock_http`](https://pub.dev/packages/openapi_mock_http): adapter for `package:http` and `chopper`
- [`openapi_mock_dio`](https://pub.dev/packages/openapi_mock_dio): adapter for `dio`
- [`openapi_mock_server`](https://pub.dev/packages/openapi_mock_server): local HTTP server adapter
- [`openapi_mock_cli`](https://pub.dev/packages/openapi_mock_cli): CLI for `method + path` resolution
