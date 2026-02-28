# openapi_mock workspace

[![Build](https://github.com/hiromu-kon/openapi_mock/actions/workflows/build.yaml/badge.svg)](https://github.com/hiromu-kon/openapi_mock/actions/workflows/build.yaml)
[![Coverage](https://codecov.io/gh/hiromu-kon/openapi_mock/graph/badge.svg)](https://codecov.io/gh/hiromu-kon/openapi_mock)
[![pub package](https://img.shields.io/pub/v/openapi_mock.svg)](https://pub.dev/packages/openapi_mock)
[![openapi_mock_cli](https://img.shields.io/pub/v/openapi_mock_cli.svg)](https://pub.dev/packages/openapi_mock_cli)
[![openapi_mock_http](https://img.shields.io/pub/v/openapi_mock_http.svg)](https://pub.dev/packages/openapi_mock_http)
[![openapi_mock_dio](https://img.shields.io/pub/v/openapi_mock_dio.svg)](https://pub.dev/packages/openapi_mock_dio)
[![openapi_mock_server](https://img.shields.io/pub/v/openapi_mock_server.svg)](https://pub.dev/packages/openapi_mock_server)
[![License](https://img.shields.io/github/license/hiromu-kon/openapi_mock.svg)](https://github.com/hiromu-kon/openapi_mock/blob/main/LICENSE)

OpenAPI-driven mock tooling for Dart, organized as a Melos monorepo.

Monorepo layout:

- `packages/openapi_mock`: core engine
- `packages/openapi_mock_http`: `package:http` adapter
- `packages/openapi_mock_dio`: `dio` adapter
- `packages/openapi_mock_server`: local server adapter
- `packages/openapi_mock_cli`: CLI package

## Packages

- `openapi_mock`: core engine published to pub.dev
- `openapi_mock_cli`: CLI package published to pub.dev
- `openapi_mock_http`: `package:http` adapter published to pub.dev
- `openapi_mock_dio`: `dio` adapter published to pub.dev
- `openapi_mock_server`: local server adapter published to pub.dev

## Melos

Setup (from repository root):

```bash
dart pub global activate melos
melos bootstrap
```

Then:

```bash
melos run analyze
melos run test
melos run test:coverage
```

Note: publishable packages use hosted dependencies in `pubspec.yaml`; local monorepo linking is managed with `pubspec_overrides.yaml`.
Coverage output is generated per package under `coverage/`.
GitHub Actions also uploads `coverage/lcov.info` as an artifact. If `CODECOV_TOKEN` is set in repository secrets, coverage is uploaded to Codecov.

## Release workflow

- `build.yaml`: formatting, analyze, test, coverage, publish dry-run
- `publish.yaml`: tag-based pub.dev publish workflow

`build.yaml` runs format, analyze, test, and coverage on the workspace.

Repository secrets:

- `CODECOV_TOKEN`: optional when using token-based Codecov upload

License:

- `MIT`

`publish.yaml` is intended for pub.dev Trusted Publishing (`id-token: write`).

Publish tag format:

- `openapi_mock-v<version>`
- `openapi_mock_cli-v<version>`
- `openapi_mock_http-v<version>`
- `openapi_mock_dio-v<version>`
- `openapi_mock_server-v<version>`

Quick start:

```bash
cd packages/openapi_mock_cli
dart run openapi_mock_cli --spec ../openapi_mock/example/openapi.yaml --method GET --path /users/42
```
