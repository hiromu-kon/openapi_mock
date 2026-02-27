import 'package:http/http.dart' as http;
import 'package:openapi_mock_http/openapi_mock_http.dart';

Future<void> main() async {
  final mock = await OpenApiMock.fromFile('example/openapi.yaml');

  final client = OpenApiMockHttpClient(
    mock: mock,
    fallback: http.Client(),
  );

  final mocked =
      await client.get(Uri.parse('https://api.example.com/users/42'));
  print('mocked status=${mocked.statusCode}');
  print('mocked body=${mocked.body}');
  client.close();

  final passthroughClient = OpenApiMockHttpClient(
    mock: mock,
    fallback: http.Client(),
    mode: MockMode.passthrough,
  );
  passthroughClient.close();
  print('passthrough mode client is ready');
}
