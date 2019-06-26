import 'package:slugify/slugify.dart';
import 'package:path/path.dart' as p;
import 'generator.dart';
import 'utils.dart';

const _markdownFileExtension = '.md';

/// Represents the resource types.
enum Resource { page, post }

/// Scaffolds a new page file with desired [title].
Future<Uri> createResource(Uri sourceDir, String title, {bool force}) async {
  // Slugify title to create a file name.
  var fileName = p.setExtension(Slugify(title), '.md');
  var metadata = <String, dynamic>{
    'title': title,
    'date': formatDate(DateTime.now()),
    'template': 'base',
    'public': false,
  };

  return createSourceFile(sourceDir.resolve(fileName),
      metadata: metadata, content: 'Hello, world!', force: force);
}

/// Lists all Markdown files in the pages directory.
Future<List<Uri>> listResources(Uri sourceDir) =>
    listDirectory(sourceDir, extension: _markdownFileExtension);

/// Compiles the files in the pages directory.
Future<List<Uri>> compileResources(
    Uri sourceDir, publicDir, templatesDir) async {
  generateHtmlFiles(
      files: await listResources(sourceDir),
      sourceDir: sourceDir,
      publicDir: publicDir,
      templatesDir: templatesDir);
}
