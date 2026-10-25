import 'fs.dart';
import 'model.dart';
import 'store.dart';

class ImportResult {
  final SunsetProject project;
  final List<String> dartFiles;

  const ImportResult(this.project, this.dartFiles);
}

class ImportException implements Exception {
  final String message;

  const ImportException(this.message);

  @override
  String toString() => 'ImportException: $message';
}

Future<ImportResult> importFlutterProject(Fs fs, String dir) async {
  final pubspec = await fs.read('$dir/pubspec.yaml');
  if (pubspec == null) {
    throw const ImportException('no pubspec.yaml found');
  }
  if (!pubspec.contains('sdk: flutter') && !pubspec.contains('flutter:')) {
    throw const ImportException('not a Flutter project');
  }

  final nameMatch = RegExp(r'^name:\s*(\S+)', multiLine: true)
      .firstMatch(pubspec);
  final name = nameMatch?.group(1) ?? 'imported';

  final files = await fs.list('$dir/lib');
  final dartFiles = [
    for (final f in files)
      if (f.endsWith('.dart')) 'lib/$f',
  ];

  final store = ProjectStore(fs);
  final existing = await store.tryLoad(dir);
  final project = existing ??
      SunsetProject(
        name: name,
        packageName: _packageOf(pubspec),
        description: 'Imported Flutter project.',
        imported: true,
      );
  project.imported = true;
  project.importedFiles = dartFiles;
  if (project.screens.isEmpty) project.addScreen('Home');
  await store.save(dir, project);
  return ImportResult(project, dartFiles);
}

String _packageOf(String pubspec) {
  final match = RegExp(r'^name:\s*(\S+)', multiLine: true).firstMatch(pubspec);
  final name = match?.group(1) ?? 'app';
  return 'com.imported.${name.replaceAll(RegExp('[^a-zA-Z0-9]'), '').toLowerCase()}';
}
