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

    test('returns null from tryResolve when no path matches', () {
      final mock = OpenApiMock.fromMap(<String, dynamic>{
        'openapi': '3.0.0',
        'paths': <String, Object?>{},
      });

      final response = mock.tryResolve(
        MockRequest(method: 'GET', path: '/not-found'),
      );

      expect(response, isNull);
    });

    test('returns null from tryResolve when method does not match', () {
      final mock = OpenApiMock.fromMap(<String, dynamic>{
        'openapi': '3.0.0',
        'paths': {
          '/users': {
            'get': {
              'responses': {
                '200': {
                  'content': {
                    'application/json': {
                      'example': <String, Object?>{'ok': true},
                    },
                  },
                },
              },
            },
          },
        },
      });

      final response = mock.tryResolve(
        MockRequest(method: 'POST', path: '/users'),
      );

      expect(response, isNull);
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

    test('parses OpenAPI from JSON string', () {
      const spec = '''
{
  "openapi": "3.0.0",
  "paths": {
    "/json": {
      "get": {
        "responses": {
          "200": {
            "content": {
              "application/json": {
                "example": {"source": "json"}
              }
            }
          }
        }
      }
    }
  }
}
''';

      final mock = OpenApiMock.fromString(spec);
      final response = mock.resolve(
        MockRequest(method: 'GET', path: '/json'),
      );

      expect(response.statusCode, 200);
      expect(response.body, <String, Object?>{'source': 'json'});
    });

    test('prefers examples over example', () {
      final mock = OpenApiMock.fromMap(<String, dynamic>{
        'openapi': '3.0.0',
        'paths': {
          '/users': {
            'get': {
              'responses': {
                '200': {
                  'content': {
                    'application/json': {
                      'examples': {
                        'first': {
                          'value': {'source': 'examples'},
                        },
                      },
                      'example': {'source': 'example'},
                    },
                  },
                },
              },
            },
          },
        },
      });

      final response = mock.resolve(
        MockRequest(method: 'GET', path: '/users'),
      );

      expect(response.body, <String, Object?>{'source': 'examples'});
    });

    test('uses schema when example does not exist', () {
      final mock = OpenApiMock.fromMap(<String, dynamic>{
        'openapi': '3.0.0',
        'paths': {
          '/schema': {
            'get': {
              'responses': {
                '200': {
                  'content': {
                    'application/json': {
                      'schema': {'type': 'object', 'title': 'Fallback'},
                    },
                  },
                },
              },
            },
          },
        },
      });

      final response = mock.resolve(
        MockRequest(method: 'GET', path: '/schema'),
      );

      expect(
        response.body,
        <String, Object?>{'type': 'object', 'title': 'Fallback'},
      );
    });

    test('selects default response when numeric status is missing', () {
      final mock = OpenApiMock.fromMap(<String, dynamic>{
        'openapi': '3.0.0',
        'paths': {
          '/default-only': {
            'get': {
              'responses': {
                'default': {
                  'content': {
                    'application/json': {
                      'example': {'message': 'default'},
                    },
                  },
                },
              },
            },
          },
        },
      });

      final response = mock.resolve(
        MockRequest(method: 'GET', path: '/default-only'),
      );

      expect(response.statusCode, 200);
      expect(response.body, <String, Object?>{'message': 'default'});
    });

    test('returns 500 when paths object is missing', () {
      final mock = OpenApiMock.fromMap(<String, dynamic>{
        'openapi': '3.0.0',
      });

      final response = mock.resolve(
        MockRequest(method: 'GET', path: '/any'),
      );

      expect(response.statusCode, 500);
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

    test('loads OpenAPI document from http URI', () async {
      late HttpServer server;
      try {
        server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      } on SocketException {
        // Some sandboxed environments disallow opening local sockets.
        return;
      }
      server.listen((request) {
        request.response.headers.contentType = ContentType.text;
        request.response.write('''
openapi: 3.0.0
paths:
  /remote:
    get:
      responses:
        '200':
          content:
            application/json:
              example:
                source: "remote"
''');
        request.response.close();
      });

      try {
        final uri = Uri.parse('http://127.0.0.1:${server.port}/openapi.yaml');
        final mock = await OpenApiMock.fromUri(uri);
        final response = mock.resolve(
          MockRequest(method: 'GET', path: '/remote'),
        );

        expect(response.statusCode, 200);
        expect(response.body, <String, Object?>{'source': 'remote'});
      } finally {
        await server.close(force: true);
      }
    });
  });
}
