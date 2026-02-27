## 0.1.0

- Initial MVP for `openapi_mock`.
- Added OpenAPI-driven mock resolver with:
  - method/path matching
  - response extraction from `x-mock-response`, `examples`, `example`
  - JSON/YAML OpenAPI document parsing
  - `application/json` then YAML media type preference
- Added adapter modules:
  - `openapi_mock_http.dart` with `OpenApiMockHttpClient`
  - `openapi_mock_dio.dart` with `OpenApiMockDioInterceptor`
  - `openapi_mock_server.dart` with `OpenApiMockServer`
