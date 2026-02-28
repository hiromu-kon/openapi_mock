import 'dart:io';

import 'package:openapi_mock_dio/openapi_mock_dio.dart';
import 'package:test/test.dart';

void main() {
  test('can create interceptor', () {
    final mock = OpenApiMock.fromMap(<String, dynamic>{
      'openapi': '3.0.0',
      'paths': <String, Object?>{},
    });

    final interceptor = OpenApiMockDioInterceptor(mock: mock);
    expect(interceptor.mode, MockMode.mixed);
  });

  test('loads interceptor from file', () async {
    final tempDir = await Directory.systemTemp.createTemp('openapi_mock_dio');
    final specFile = File('${tempDir.path}/openapi.yaml');
    await specFile.writeAsString('''
openapi: 3.0.0
paths:
  /users/1:
    get:
      responses:
        '200':
          content:
            application/json:
              example:
                id: "1"
''');

    final interceptor = await OpenApiMockDioInterceptor.fromFile(specFile.path);
    expect(interceptor.mode, MockMode.mixed);

    await tempDir.delete(recursive: true);
  });
}
