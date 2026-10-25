// coverage:ignore-file
import 'dart:io';

import '../core/fs_io.dart';
import '../core/platform/platform_io.dart';
import 'runner.dart';

CliIo cliIo({String? cwd}) => CliIo(
  fs: IoFs(),
  git: defaultGitRun(),
  out: stdout.writeln,
  err: stderr.writeln,
  cwd: cwd ?? Directory.current.path,
);
