import 'dart:convert';
import 'dart:io';

import 'package:openapi_mock_server/openapi_mock_server.dart';
import 'package:test/test.dart';

void main() {
  test('serves example response', () async {
    final mock = OpenApiMock.fromMap(<String, dynamic>{
      'openapi': '3.0.0',
      'paths': {
        '/ping': {
          'get': {
            'responses': {
              '200': {
                'content': {
                  'application/json': {
                    'example': {'ok': true},
                  },
                },
              },
            },
          },
        },
      },
    });

    late OpenApiMockServer server;
    try {
      server = await OpenApiMockServer.start(mock: mock);
    } on SocketException {
      // Some sandboxed environments disallow opening local sockets.
      return;
    }
    try {
      final client = HttpClient();
      final request = await client.getUrl(server.baseUri.resolve('/ping'));
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      client.close(force: true);

      expect(response.statusCode, 200);
      expect(jsonDecode(body), <String, Object?>{'ok': true});
    } finally {
      await server.close(force: true);
    }
  });

  test('starts server from file', () async {
    final tempDir =
        await Directory.systemTemp.createTemp('openapi_mock_server');
    final specFile = File('${tempDir.path}/openapi.yaml');
    await specFile.writeAsString('''
openapi: 3.0.0
paths:
  /health:
    get:
      responses:
        '200':
          content:
            application/json:
              example:
                status: ok
''');

    late OpenApiMockServer server;
    try {
      server = await OpenApiMockServer.fromFile(path: specFile.path);
    } on SocketException {
      // Some sandboxed environments disallow opening local sockets.
      await tempDir.delete(recursive: true);
      return;
    }
    try {
      final client = HttpClient();
      final request = await client.getUrl(server.baseUri.resolve('/health'));
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      client.close(force: true);

      expect(response.statusCode, 200);
      expect(jsonDecode(body), <String, Object?>{'status': 'ok'});
    } finally {
      await server.close(force: true);
      await tempDir.delete(recursive: true);
    }
  });
}
