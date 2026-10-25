import 'dart:io';

import 'fs.dart';

class IoFs implements Fs {
  @override
  Future<String?> read(String path) async {
    final file = File(path);
    if (!file.existsSync()) return null;
    return file.readAsString();
  }

  @override
  Future<void> write(String path, String contents) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(contents);
  }

  @override
  Future<bool> exists(String path) async =>
      File(path).existsSync() || Directory(path).existsSync();

  @override
  Future<bool> isDir(String path) async => Directory(path).existsSync();

  @override
  Future<List<String>> list(String dir) async {
    final root = Directory(dir);
    if (!root.existsSync()) return const [];
    final result = <String>[];
    await for (final entity in root.list(recursive: true)) {
      var rel = entity.path.substring(root.path.length);
      if (rel.startsWith('/') || rel.startsWith('\\')) rel = rel.substring(1);
      if (entity is Directory) rel = '$rel/';
      result.add(rel);
    }
    return result..sort();
  }

  @override
  Future<void> delete(String path) async {
    if (await File(path).exists()) {
      await File(path).delete(recursive: true);
    } else if (await Directory(path).exists()) {
      await Directory(path).delete(recursive: true);
    }
  }
}
