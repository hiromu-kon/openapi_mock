import 'dart:io';

import 'package:openapi_mock/openapi_mock.dart';
import 'package:test/test.dart';

void main() {
  group('OpenApiMock', () {
    test('returns response from example', () {
      final mock = OpenApiMock.fromMap(<String, dynamic>{
        'openapi': '3.0.0',
        'paths': {
          '/users/{id}': {
            'get': {
              'responses': {
                '200': {
                  'content': {
                    'application/json': {
                      'example': {'id': '1', 'name': 'Hanako'},
                    },
                  },
                },
              },
            },
          },
        },
      });

      final response = mock.resolve(
        MockRequest(method: 'GET', path: '/users/1'),
      );

      expect(response.statusCode, 200);
      expect(response.headers['content-type'], 'application/json');
      expect(response.body, <String, Object?>{'id': '1', 'name': 'Hanako'});
    });

    test('uses x-mock-response with highest priority', () {
      final mock = OpenApiMock.fromMap(<String, dynamic>{
        'openapi': '3.0.0',
        'paths': {
          '/users/me': {
            'get': {
              'x-mock-response': {
                'statusCode': 202,
                'headers': {'x-source': 'extension'},
                'body': {'ok': true},
              },
              'responses': {
                '200': {
                  'content': {
                    'application/json': {
                      'example': {'ignored': true},
                    },
                  },
                },
              },
            },
          },
        },
      });

      final response = mock.resolve(
        MockRequest(method: 'GET', path: '/users/me'),
      );

      expect(response.statusCode, 202);
      expect(response.headers['x-source'], 'extension');
      expect(response.body, <String, Object?>{'ok': true});
    });

    test('returns 404 when no path matches', () {
      final mock = OpenApiMock.fromMap(<String, dynamic>{
        'openapi': '3.0.0',
        'paths': <String, Object?>{},
      });

      final response = mock.resolve(
        MockRequest(method: 'GET', path: '/not-found'),
      );

      expect(response.statusCode, 404);
    });

    test('parses OpenAPI from YAML string', () {
      const spec = '''
openapi: 3.0.0
paths:
  /todos/{id}:
    get:
      responses:
        '200':
          content:
            application/json:
              example:
                id: "10"
                title: "Write tests"
''';

      final mock = OpenApiMock.fromYamlString(spec);
      final response = mock.resolve(
        MockRequest(method: 'GET', path: '/todos/10'),
      );

      expect(response.statusCode, 200);
      expect(
        response.body,
        <String, Object?>{'id': '10', 'title': 'Write tests'},
      );
    });

    test('auto-detects YAML from generic string constructor', () {
      const spec = '''
openapi: 3.0.0
paths:
  /ping:
    get:
      responses:
        '200':
          content:
            application/json:
              example:
                ok: true
''';

      final mock = OpenApiMock.fromString(spec);
      final response = mock.resolve(
        MockRequest(method: 'GET', path: '/ping'),
      );

      expect(response.statusCode, 200);
      expect(response.body, <String, Object?>{'ok': true});
    });

    test('loads OpenAPI document from file', () async {
      final tempDir =
          await Directory.systemTemp.createTemp('openapi_mock_test');
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
                status: "ok"
''');

      final mock = await OpenApiMock.fromFile(specFile.path);
      final response = mock.resolve(
        MockRequest(method: 'GET', path: '/health'),
      );

      expect(response.statusCode, 200);
      expect(response.body, <String, Object?>{'status': 'ok'});

      await tempDir.delete(recursive: true);
    });

    test('loads OpenAPI document from file URI', () async {
      final tempDir =
          await Directory.systemTemp.createTemp('openapi_mock_test');
      final specFile = File('${tempDir.path}/openapi.yaml');
      await specFile.writeAsString('''
openapi: 3.0.0
paths:
  /version:
    get:
      responses:
        '200':
          content:
            application/json:
              example:
                value: "1.0.0"
''');

      final mock = await OpenApiMock.fromUri(specFile.uri);
      final response = mock.resolve(
        MockRequest(method: 'GET', path: '/version'),
      );

      expect(response.statusCode, 200);
      expect(response.body, <String, Object?>{'value': '1.0.0'});

      await tempDir.delete(recursive: true);
    });
  });
}
