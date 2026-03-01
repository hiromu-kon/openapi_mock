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

## Packages

- [`openapi_mock`](https://pub.dev/packages/openapi_mock): core engine for resolving mock responses from an OpenAPI document
- [`openapi_mock_http`](https://pub.dev/packages/openapi_mock_http): `package:http` adapter, also usable from `chopper`
- [`openapi_mock_dio`](https://pub.dev/packages/openapi_mock_dio): `dio` interceptor adapter
- [`openapi_mock_server`](https://pub.dev/packages/openapi_mock_server): local HTTP mock server
- [`openapi_mock_cli`](https://pub.dev/packages/openapi_mock_cli): CLI for resolving a mock response from `method + path`

Repository layout:

- `packages/openapi_mock`
- `packages/openapi_mock_http`
- `packages/openapi_mock_dio`
- `packages/openapi_mock_server`
- `packages/openapi_mock_cli`

## Which package should I use?

- App code that needs OpenAPI-based mock resolution: `openapi_mock`
- `package:http` or `chopper` integration: `openapi_mock_http`
- `dio` integration: `openapi_mock_dio`
- Local mock server with `baseUrl` switching: `openapi_mock_server`
- Command-line usage in CI or local development: `openapi_mock_cli`

## Melos

Setup from repository root:

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

Coverage output is generated per package under `coverage/`.
GitHub Actions also uploads `coverage/lcov.info` as an artifact. If `CODECOV_TOKEN` is set in repository secrets, coverage is uploaded to Codecov.

## Release workflow

- `build.yaml`: formatting, analyze, test, coverage
- `publish.yaml`: tag-based pub.dev publish workflow
- `.github/actions/pub-publish`: shared composite action for package publishing

`build.yaml` runs format, analyze, test, and coverage on the workspace.
`publish.yaml` is intended for pub.dev Trusted Publishing (`id-token: write`).

Repository secrets:

- `CODECOV_TOKEN`: optional when using token-based Codecov upload

Publish tag format:

- `openapi_mock-v<version>`
- `openapi_mock_cli-v<version>`
- `openapi_mock_http-v<version>`
- `openapi_mock_dio-v<version>`
- `openapi_mock_server-v<version>`

## Quick start

```bash
cd packages/openapi_mock_cli
dart run openapi_mock_cli --spec ../openapi_mock/example/openapi.yaml --method GET --path /users/42
```
