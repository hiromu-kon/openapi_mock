## 0.0.1

- Initial MVP for `openapi_mock` core.
- Added OpenAPI-driven mock resolver with:
  - method/path matching
  - response extraction from `x-mock-response`, `examples`, `example`
  - JSON/YAML OpenAPI document parsing
  - `application/json` then YAML media type preference
- Added loaders: `fromFile`, `fromUri`.
