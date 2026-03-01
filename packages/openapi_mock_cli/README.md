# openapi_mock_cli

[![pub package](https://img.shields.io/pub/v/openapi_mock_cli.svg)](https://pub.dev/packages/openapi_mock_cli)

CLI for [`openapi_mock`](https://pub.dev/packages/openapi_mock).

## Installation

```bash
dart pub global activate openapi_mock_cli
```

## Usage

```bash
dart run openapi_mock_cli --spec openapi.yaml --method GET --path /users/42
```

Or, after global activation:

```bash
openapi_mock_cli --spec openapi.yaml --method GET --path /users/42
```

Options:

- `--spec`: OpenAPI file path or URI (`file://`, `http://`, `https://`)
- `--method`: HTTP method (default: `GET`)
- `--path`: request path such as `/users/42`
- `--full`: print the full response object (`statusCode`, `headers`, `body`)

Default output is the mock response body as JSON.

## Full response output

```bash
openapi_mock_cli --spec openapi.yaml --method GET --path /users/42 --full
```

## Related packages

- [`openapi_mock`](https://pub.dev/packages/openapi_mock): core engine used by this CLI
- [`openapi_mock_http`](https://pub.dev/packages/openapi_mock_http): `package:http` adapter
- [`openapi_mock_dio`](https://pub.dev/packages/openapi_mock_dio): `dio` adapter
- [`openapi_mock_server`](https://pub.dev/packages/openapi_mock_server): local server adapter
