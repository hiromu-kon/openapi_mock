import 'dart:convert';
import 'dart:io';

import 'package:openapi_mock_server/openapi_mock_server.dart';

Future<void> main() async {
  final server = await OpenApiMockServer.fromFile(path: 'example/openapi.yaml');
  try {
    final uri = server.baseUri.resolve('/users/42');
    final client = HttpClient();
    final request = await client.getUrl(uri);
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    client.close(force: true);

    print('server=${server.baseUri}');
    print('status=${response.statusCode}');
    print('body=${jsonDecode(body)}');
  } finally {
    await server.close(force: true);
  }
}
