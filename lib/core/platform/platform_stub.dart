// coverage:ignore-file
import '../fs.dart';
import '../git_service.dart';

final MemFs _shared = MemFs();

Fs defaultFs() => _shared;

ProcRun defaultGitRun() => (args, cwd) async =>
    const ProcResult(128, '', 'git is not available on this platform');

Future<String?> pickProjectDir() async => null;

Future<bool> saveFilePicker(String name, List<int> bytes) async => false;
