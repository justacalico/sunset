import 'dart:io';

import 'package:sunset/cli/cli_io.dart';
import 'package:sunset/cli/runner.dart';

Future<void> main(List<String> args) async {
  exitCode = await runCli(args, io: cliIo());
}
