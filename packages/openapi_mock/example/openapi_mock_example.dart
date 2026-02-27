import 'dart:convert';

import 'package:openapi_mock/openapi_mock.dart';

Future<void> main() async {
  final mock = await OpenApiMock.fromFile('example/openapi.yaml');
  final response = mock.resolve(
    MockRequest(method: 'GET', path: '/users/42'),
  );

  print('status=${response.statusCode}');
  print('headers=${response.headers}');
  print('body=${jsonEncode(response.body)}');
}
