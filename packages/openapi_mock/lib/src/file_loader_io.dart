import 'dart:convert';
import 'dart:io';

Future<String> readTextFile(String path) => File(path).readAsString();

Future<String> readTextUri(Uri uri) async {
  if (uri.scheme.isEmpty || uri.scheme == 'file') {
    return File.fromUri(uri).readAsString();
  }
  if (uri.scheme == 'http' || uri.scheme == 'https') {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Failed to load OpenAPI document: HTTP ${response.statusCode}',
          uri: uri,
        );
      }
      return response.transform(utf8.decoder).join();
    } finally {
      client.close(force: true);
    }
  }
  throw UnsupportedError(
    'Unsupported URI scheme for OpenApiMock.fromUri: ${uri.scheme}',
  );
}
