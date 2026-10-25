// coverage:ignore-file
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

import '../fs.dart';
import '../fs_io.dart';
import '../git_service.dart';

Fs defaultFs() => IoFs();

ProcRun defaultGitRun() => (args, cwd) async {
  final result = await Process.run('git', args, workingDirectory: cwd);
  return ProcResult(result.exitCode, '${result.stdout}', '${result.stderr}');
};

Future<String?> pickProjectDir() => getDirectoryPath();

Future<bool> saveFilePicker(String name, List<int> bytes) async {
  final location = await getSaveLocation(suggestedName: name);
  if (location == null) return false;
  await File(location.path).writeAsBytes(Uint8List.fromList(bytes));
  return true;
}
