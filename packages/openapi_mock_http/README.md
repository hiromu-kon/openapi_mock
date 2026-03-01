# openapi_mock_http

[![pub package](https://img.shields.io/pub/v/openapi_mock_http.svg)](https://pub.dev/packages/openapi_mock_http)

HTTP adapter package for [`openapi_mock`](https://pub.dev/packages/openapi_mock).

## Installation

```yaml
dependencies:
  openapi_mock: ^0.0.1
  openapi_mock_http: ^0.0.1
```

## Usage

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

`MockMode.mixed` is useful when you want only matched endpoints to be mocked.

## Chopper

`chopper` uses `package:http`, so you can pass `OpenApiMockHttpClient` directly to `ChopperClient`.

```dart
final chopper = ChopperClient(
  baseUrl: Uri.parse('https://api.example.com'),
  client: client,
  converter: const JsonConverter(),
);
```

## Related packages

- [`openapi_mock`](https://pub.dev/packages/openapi_mock): core engine
- [`openapi_mock_dio`](https://pub.dev/packages/openapi_mock_dio): `dio` adapter
- [`openapi_mock_server`](https://pub.dev/packages/openapi_mock_server): local server adapter
- [`openapi_mock_cli`](https://pub.dev/packages/openapi_mock_cli): CLI package
