import 'dart:io';

import 'package:openapi_mock_cli/openapi_mock_cli.dart';
import 'package:test/test.dart';

void main() {
  Future<File> createSpecFile() async {
    final tempDir = await Directory.systemTemp.createTemp('openapi_mock_cli');
    final specFile = File('${tempDir.path}/openapi.yaml');
    await specFile.writeAsString('''
openapi: 3.0.0
paths:
  /users/42:
    get:
      responses:
        '200':
          content:
            application/json:
              example:
                id: "42"
''');
    addTearDown(() async {
      await tempDir.delete(recursive: true);
    });
    return specFile;
  }

  test('returns 64 when required arguments are missing', () async {
    final code = await runCli(<String>[]);
    expect(code, 64);
  });

  test('returns 0 for matched endpoint', () async {
    final specFile = await createSpecFile();
    final code = await runCli(<String>[
      '--spec',
      specFile.path,
      '--method',
      'GET',
      '--path',
      '/users/42',
    ]);
    expect(code, 0);
  });

  test('returns 1 for unmatched endpoint', () async {
    final specFile = await createSpecFile();
    final code = await runCli(<String>[
      '--spec',
      specFile.path,
      '--method',
      'GET',
      '--path',
      '/users/100',
    ]);
    expect(code, 1);
  });

  test('returns 0 when help flag is set', () async {
    final code = await runCli(<String>['--help']);
    expect(code, 0);
  });
}
