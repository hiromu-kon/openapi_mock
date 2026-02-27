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

    final server = await OpenApiMockServer.start(mock: mock);
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
}
