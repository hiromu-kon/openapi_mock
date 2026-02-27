# openapi_mock_cli

CLI for `openapi_mock`.

## Usage

```bash
dart run openapi_mock_cli --spec ../openapi_mock/example/openapi.yaml --method GET --path /users/42
```

Options:
- `--spec`: OpenAPI file path or URI (`file://`, `http://`, `https://`)
- `--method`: HTTP method (default: `GET`)
- `--path`: request path (example: `/users/42`)
- `--full`: print full response object (`statusCode`, `headers`, `body`)

Default output is the mock response body as JSON.
