# openapi_mock_dio

[![pub package](https://img.shields.io/pub/v/openapi_mock_dio.svg)](https://pub.dev/packages/openapi_mock_dio)

Dio interceptor adapter package for [`openapi_mock`](https://pub.dev/packages/openapi_mock).

## Installation

```yaml
dependencies:
  openapi_mock: ^0.0.1
  openapi_mock_dio: ^0.0.1
```

## Usage

```dart
import 'package:dio/dio.dart';
import 'package:openapi_mock_dio/openapi_mock_dio.dart';

final dio = Dio();
dio.interceptors.add(
  await OpenApiMockDioInterceptor.fromFile('openapi.yaml'),
);
```

Use `MockMode.mixed` when you want matched endpoints to be mocked and unmatched endpoints to continue to the real API.

```dart
dio.interceptors.add(
  await OpenApiMockDioInterceptor.fromFile(
    'openapi.yaml',
    mode: MockMode.mixed,
  ),
);
```

## Related packages

- [`openapi_mock`](https://pub.dev/packages/openapi_mock): core engine
- [`openapi_mock_http`](https://pub.dev/packages/openapi_mock_http): `package:http` and `chopper` adapter
- [`openapi_mock_server`](https://pub.dev/packages/openapi_mock_server): local server adapter
- [`openapi_mock_cli`](https://pub.dev/packages/openapi_mock_cli): CLI package
