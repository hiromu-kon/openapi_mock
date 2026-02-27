import 'package:openapi_mock_cli/openapi_mock_cli.dart';
import 'package:test/test.dart';

void main() {
  test('returns 64 when required arguments are missing', () async {
    final code = await runCli(<String>[]);
    expect(code, 64);
  });
}
