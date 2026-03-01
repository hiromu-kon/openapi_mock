# openapi_mock_server

[![pub package](https://img.shields.io/pub/v/openapi_mock_server.svg)](https://pub.dev/packages/openapi_mock_server)

Local HTTP server adapter package for [`openapi_mock`](https://pub.dev/packages/openapi_mock).

## Installation

```yaml
dependencies:
  openapi_mock: ^0.0.1
  openapi_mock_server: ^0.0.1
```

## Usage

```dart
import 'package:openapi_mock_server/openapi_mock_server.dart';

final server = await OpenApiMockServer.fromFile(path: 'openapi.yaml');
print(server.baseUri);
```

This package is useful when you want to switch an application's `baseUrl` to a local mock server instead of using an interceptor-based adapter.

## Related packages

- [`openapi_mock`](https://pub.dev/packages/openapi_mock): core engine
- [`openapi_mock_http`](https://pub.dev/packages/openapi_mock_http): `package:http` and `chopper` adapter
- [`openapi_mock_dio`](https://pub.dev/packages/openapi_mock_dio): `dio` adapter
- [`openapi_mock_cli`](https://pub.dev/packages/openapi_mock_cli): CLI package
