Future<String> readTextFile(String path) => Future<String>.error(
      UnsupportedError(
          'OpenApiMock.fromFile is only supported on dart:io platforms.'),
    );

Future<String> readTextUri(Uri uri) => Future<String>.error(
      UnsupportedError(
          'OpenApiMock.fromUri is only supported on dart:io platforms.'),
    );
