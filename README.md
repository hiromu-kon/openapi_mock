# openapi_mock workspace

Monorepo layout:

- `packages/openapi_mock`: core engine
- `packages/openapi_mock_http`: `package:http` adapter
- `packages/openapi_mock_dio`: `dio` adapter
- `packages/openapi_mock_server`: local server adapter
- `packages/openapi_mock_cli`: CLI package

## Melos

Setup (from repository root):

```bash
dart pub get
dart run melos bootstrap
```

Then:

```bash
dart run melos run analyze
dart run melos run test
```

Note: publishable packages use hosted dependencies in `pubspec.yaml`; local monorepo linking is managed with `pubspec_overrides.yaml`.

Quick start:

```bash
cd packages/openapi_mock_cli
dart run openapi_mock_cli --spec ../openapi_mock/example/openapi.yaml --method GET --path /users/42
```
