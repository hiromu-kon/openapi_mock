# openapi_mock

`openapi_mock` is an OpenAPI-driven mock toolkit for Dart and Flutter.

## Architecture

- `openapi_mock.dart`:
  Core resolver (`OpenApiMock`)
- `openapi_mock_http.dart`:
  `package:http` client adapter (`OpenApiMockHttpClient`)
- `openapi_mock_dio.dart`:
  `dio` interceptor adapter (`OpenApiMockDioInterceptor`)
- `openapi_mock_server.dart`:
  local mock server (`OpenApiMockServer`)

## Current MVP

- Method + path matching (supports `/users/{id}`)
- OpenAPI input parsing from JSON and YAML
- Response selection from OpenAPI `responses`
- Example priority: `x-mock-response` > `examples` > `example`
- `application/json` then YAML preference when multiple content types exist

## Core usage

```dart
import 'dart:convert';
import 'package:openapi_mock/openapi_mock.dart';

void main() {
  final spec = <String, dynamic>{
    'openapi': '3.0.0',
    'paths': {
      '/users/{id}': {
        'get': {
          'responses': {
            '200': {
              'content': {
                'application/json': {
                  'example': {'id': '42', 'name': 'Taro'}
                }
              }
            }
          }
        }
      }
    }
  };

final mock = OpenApiMock.fromMap(spec);
  final response = mock.resolve(
    MockRequest(method: 'GET', path: '/users/42'),
  );

  print(response.statusCode); // 200
  print(jsonEncode(response.body)); // {"id":"42","name":"Taro"}
}
```

You can load OpenAPI from text or file:

```dart
final mockFromJson = OpenApiMock.fromJsonString(jsonText);
final mockFromYaml = OpenApiMock.fromYamlString(yamlText);
final mockAuto = OpenApiMock.fromString(documentText); // JSON -> YAML fallback
final mockFromFile = await OpenApiMock.fromFile('openapi.yaml');
final mockFromUri = await OpenApiMock.fromUri(Uri.parse('https://example.com/openapi.yaml'));
```

## HTTP adapter (Chopper compatible)

```dart
import 'package:http/http.dart' as http;
import 'package:openapi_mock/openapi_mock_http.dart';

final mock = await OpenApiMock.fromFile('openapi.yaml');

final client = OpenApiMockHttpClient(
  mock: mock,
  fallback: http.Client(),
  mode: MockMode.mixed, // matched: mock, unmatched: real API
);
```

For `chopper`, pass the `client` above to `ChopperClient(client: ...)`.

## Dio adapter

```dart
import 'package:dio/dio.dart';
import 'package:openapi_mock/openapi_mock_dio.dart';

final dio = Dio();
dio.interceptors.add(
  await OpenApiMockDioInterceptor.fromFile(
    'openapi.yaml',
    mode: MockMode.mixed,
  ),
);
```

## Local server adapter

```dart
import 'package:openapi_mock/openapi_mock_server.dart';

final server = await OpenApiMockServer.fromFile(path: 'openapi.yaml');
print(server.baseUri); // http://127.0.0.1:xxxxx
```

See runnable samples in `example/`:
- `example/core_example.dart`
- `example/http_adapter_example.dart`
- `example/dio_adapter_example.dart`
- `example/server_example.dart`

## CLI

This repository also includes a separate CLI package: `../openapi_mock_cli/`.

Example:
```bash
cd ../openapi_mock_cli
dart run openapi_mock_cli --spec ../openapi_mock/example/openapi.yaml --method GET --path /users/42
```
