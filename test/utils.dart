import 'dart:io';
import 'package:tota/tota.dart';

/// Creates a temp directory in the system temp directory, whose name will be
/// 'tota_' with characters appended to it to make a unique name.
///
/// Returns the path of the created directory.
String _createSystemTempDir() {
  var tempDir = Directory.systemTemp.createTempSync('tota_');
  return tempDir.resolveSymbolicLinksSync();
}

/// Creates a temporary directory and passes its path to [fn].
///
/// Once the [Future] returned by [fn] completes, the temporary directory and
/// all its contents are deleted. [fn] can also return `null`, in which case
/// the temporary directory is deleted immediately afterwards.
///
/// Returns a future that completes to the value that the future returned from
/// [fn] completes to.
Future<T> withTempDir<T>(Future<T> fn(String path)) async {
  var tempDir = _createSystemTempDir();
  try {
    return await fn(tempDir);
  } finally {
    await Directory(tempDir).delete(recursive: true);
  }
}

/// Creates a test config with [path] as root directory.
Config createTestConfig(String path) {
  return createConfig(
    url: 'https://test',
    title: 'test',
    description: 'test',
    author: 'test',
    language: 'en',
    rootDir: path,
    publicDir: 'public/',
    pagesDir: 'pages/',
    postsDir: 'posts/',
    templatesDir: 'templates/',
    assetsDir: 'assets/',
  );
}

/// Creates test files in the temp directory.
///
/// Bootstraps a directory in the [tempDir] path, with test files
/// to run the test suite against.
Map<String, dynamic> createTestFiles(Config config, List<String> fileIds) {
  Uri tempDir = Uri.directory(config.rootDir);
  Uri pagesDir = tempDir.resolve(config.pagesDir);

  // Generate test pages.
  var files = List<Uri>.generate(
      fileIds.length, (i) => pagesDir.resolve('test-${fileIds[i]}.md'));

  // Write file contents.
  files.asMap().forEach((i, uri) {
    File.fromUri(uri)
      ..createSync(recursive: true)
      ..writeAsStringSync('---\n'
          'test: "${fileIds[i]}"\n'
          'public: true\n'
          '---\n'
          '# Hello, world!');
  });

  // Create test HTML templates.
  var templatesDir = tempDir.resolve(config.templatesDir);
  File.fromUri(templatesDir.resolve('_partials/head.mustache'))
    ..createSync(recursive: true)
    ..writeAsStringSync('{{partial}}');
  File.fromUri(templatesDir.resolve('base.mustache'))
    ..writeAsStringSync('{{content}}');

  // Create asset directory and asset file.
  var assetsDir = tempDir.resolve(config.assetsDir);
  File.fromUri(assetsDir.resolve('index.js'))
    ..createSync(recursive: true)
    ..writeAsStringSync('console.log("foo")');

  return <String, dynamic>{
    'files': files,
    'pagesDir': pagesDir,
    'templatesDir': templatesDir,
    'assetsDir': assetsDir,
    'publicDir': tempDir.resolve(config.publicDir)
  };
}
