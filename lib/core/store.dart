import 'fs.dart';
import 'model.dart';

class ProjectStore {
  final Fs fs;

  const ProjectStore(this.fs);

  static const fileName = 'project.sunset.json';

  String _file(String dir) => '$dir/$fileName';

  Future<bool> existsAt(String dir) => fs.exists(_file(dir));

  Future<SunsetProject> create(
    String dir, {
    required String name,
    String? packageName,
    String description = '',
  }) async {
    final project = SunsetProject.create(name, packageName: packageName)
      ..description = description;
    await save(dir, project);
    return project;
  }

  Future<SunsetProject> load(String dir) async {
    final source = await fs.read(_file(dir));
    if (source == null) {
      throw StateError('no Sunset project at $dir');
    }
    return SunsetProject.decode(source);
  }

  Future<SunsetProject?> tryLoad(String dir) async {
    final source = await fs.read(_file(dir));
    return source == null ? null : SunsetProject.decode(source);
  }

  Future<void> save(String dir, SunsetProject project) =>
      fs.write(_file(dir), project.encode());
}
