import 'dart:io';

import 'package:openapi_mock_cli/openapi_mock_cli.dart';

Future<void> main(List<String> args) async {
  final code = await runCli(args);
  exitCode = code;
}
