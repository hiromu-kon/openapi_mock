import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openapi_mock_http/openapi_mock_http.dart';
import 'package:test/test.dart';

void main() {
  test('uses fallback when endpoint is unmatched in mixed mode', () async {
    final mock = OpenApiMock.fromMap(<String, dynamic>{
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

    final fallback = MockClient((_) async => http.Response(
          jsonEncode(<String, Object?>{'source': 'fallback'}),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        ));

    final client = OpenApiMockHttpClient(
      mock: mock,
      fallback: fallback,
    );

    final response =
        await client.get(Uri.parse('https://api.example.com/health'));
    expect(response.statusCode, 200);
    expect(response.body, '{"source":"fallback"}');
  });
}
