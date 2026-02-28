import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openapi_mock_http/openapi_mock_http.dart';
import 'package:test/test.dart';

void main() {
  OpenApiMock createMock() {
    return OpenApiMock.fromMap(<String, dynamic>{
      'openapi': '3.0.0',
      'paths': {
        '/users/{id}': {
          'get': {
            'responses': {
              '200': {
                'content': {
                  'application/json': {
                    'example': {'id': '1'},
                  },
                },
              },
            },
          },
        },
      },
    });
  }

  test('returns mock response for matched endpoint', () async {
    final fallback = MockClient((_) async {
      return http.Response('{"source":"fallback"}', 200);
    });

    final client = OpenApiMockHttpClient(
      mock: createMock(),
      fallback: fallback,
    );

    final response =
        await client.get(Uri.parse('https://api.example.com/users/1'));
    expect(response.statusCode, 200);
    expect(response.body, '{"id":"1"}');
  });

  test('uses fallback when endpoint is unmatched in mixed mode', () async {
    final fallback = MockClient((_) async => http.Response(
          jsonEncode(<String, Object?>{'source': 'fallback'}),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        ));

    final client = OpenApiMockHttpClient(
      mock: createMock(),
      fallback: fallback,
    );

    final response =
        await client.get(Uri.parse('https://api.example.com/health'));
    expect(response.statusCode, 200);
    expect(response.body, '{"source":"fallback"}');
  });

  test('uses fallback for passthrough mode even when endpoint matches',
      () async {
    final fallback = MockClient((_) async {
      return http.Response('{"source":"network"}', 200);
    });

    final client = OpenApiMockHttpClient(
      mock: createMock(),
      fallback: fallback,
      mode: MockMode.passthrough,
    );

    final response =
        await client.get(Uri.parse('https://api.example.com/users/1'));
    expect(response.statusCode, 200);
    expect(response.body, '{"source":"network"}');
  });

  test('loads spec from file via factory constructor', () async {
    final tempDir = await Directory.systemTemp.createTemp('openapi_mock_http');
    final spec = File('${tempDir.path}/openapi.yaml');
    await spec.writeAsString('''
openapi: 3.0.0
paths:
  /todos/1:
    get:
      responses:
        '200':
          content:
            application/json:
              example:
                ok: true
''');

    final client = await OpenApiMockHttpClient.fromFile(
      path: spec.path,
      fallback: MockClient((_) async => http.Response('not-used', 500)),
    );
    try {
      final response =
          await client.get(Uri.parse('https://api.example.com/todos/1'));
      expect(response.statusCode, 200);
      expect(response.body, '{"ok":true}');
    } finally {
      client.close();
      await tempDir.delete(recursive: true);
    }
  });
}
