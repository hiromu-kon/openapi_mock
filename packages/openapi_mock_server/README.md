# openapi_mock_server

Local HTTP server adapter package for `openapi_mock`.

```dart
import 'package:openapi_mock_server/openapi_mock_server.dart';

final server = await OpenApiMockServer.fromFile(path: 'openapi.yaml');
print(server.baseUri);
```
