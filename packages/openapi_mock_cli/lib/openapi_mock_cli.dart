import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:openapi_mock/openapi_mock.dart';

Future<int> runCli(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('spec',
        abbr: 's', help: 'OpenAPI path or URI', valueHelp: 'PATH_OR_URI')
    ..addOption('method', abbr: 'm', defaultsTo: 'GET', help: 'HTTP method')
    ..addOption('path', abbr: 'p', help: 'Request path, e.g. /users/42')
    ..addFlag('full', defaultsTo: false, help: 'Print full response object')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help');

  late ArgResults args;
  try {
    args = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln(_usage(parser));
    return 64;
  }

  if (args['help'] as bool) {
    stdout.writeln(_usage(parser));
    return 0;
  }

  final spec = args['spec'] as String?;
  final method = (args['method'] as String).toUpperCase();
  final path = args['path'] as String?;
  final full = args['full'] as bool;

  if (spec == null || spec.isEmpty || path == null || path.isEmpty) {
    stderr.writeln('Both --spec and --path are required.');
    stderr.writeln(_usage(parser));
    return 64;
  }

  final mock = await _loadSpec(spec);
  final response = mock.resolve(
    MockRequest(method: method, path: path),
  );

  if (full) {
    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'statusCode': response.statusCode,
        'headers': response.headers,
        'body': response.body,
      }),
    );
  } else {
    stdout.writeln(jsonEncode(response.body));
  }

  return response.statusCode >= 400 ? 1 : 0;
}

Future<OpenApiMock> _loadSpec(String spec) async {
  final uri = Uri.tryParse(spec);
  if (uri != null && uri.hasScheme) {
    return OpenApiMock.fromUri(uri);
  }
  return OpenApiMock.fromFile(spec);
}

String _usage(ArgParser parser) {
  return 'Usage: dart run openapi_mock_cli --spec <path-or-uri> --path <request-path> '
      '[--method GET] [--full]\n\n${parser.usage}';
}
