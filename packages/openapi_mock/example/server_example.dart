import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openapi_mock/openapi_mock_server.dart';

Future<void> main() async {
  final server = await OpenApiMockServer.fromFile(path: 'example/openapi.yaml');
  try {
    final uri = server.baseUri.resolve('/users/42');
    final response = await http.get(uri);

    print('server=${server.baseUri}');
    print('status=${response.statusCode}');
    print('body=${jsonDecode(response.body)}');
  } finally {
    await server.close(force: true);
  }
}
