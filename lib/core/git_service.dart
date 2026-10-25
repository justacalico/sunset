class ProcResult {
  final int code;
  final String out;
  final String err;

  const ProcResult(this.code, this.out, this.err);
}

typedef ProcRun = Future<ProcResult> Function(List<String> args, String cwd);

class GitFile {
  final String status;
  final String path;

  const GitFile(this.status, this.path);
}

class GitCommit {
  final String hash;
  final String subject;
  final String date;

  const GitCommit(this.hash, this.subject, this.date);
}

class GitException implements Exception {
  final String message;

  const GitException(this.message);

  @override
  String toString() => 'GitException: $message';
}

class GitService {
  final ProcRun run;

  const GitService(this.run);

  Future<ProcResult> _git(String cwd, List<String> args) async {
    final result = await run(args, cwd);
    if (result.code != 0) {
      throw GitException(
        result.err.trim().isEmpty
            ? 'git ${args.join(' ')} exited ${result.code}'
            : result.err.trim(),
      );
    }
    return result;
  }

  Future<bool> isRepo(String dir) async {
    final result = await run(['rev-parse', '--is-inside-work-tree'], dir);
    return result.code == 0 && result.out.trim() == 'true';
  }

  Future<void> init(String dir) async {
    await _git(dir, ['init']);
  }

  Future<List<GitFile>> status(String dir) async {
    final result = await _git(dir, ['status', '--porcelain']);
    return [
      for (final line in result.out.split('\n'))
        if (line.length > 3)
          GitFile(line.substring(0, 2).trim(), line.substring(3).trim()),
    ];
  }

  Future<List<GitCommit>> log(String dir, {int limit = 20}) async {
    final result = await _git(dir, [
      'log',
      '--format=%h%x1f%s%x1f%aI',
      '-n',
      '$limit',
    ]);
    return [
      for (final line in result.out.split('\n'))
        if (line.contains('\x1f'))
          (() {
            final parts = line.split('\x1f');
            return GitCommit(
              parts[0],
              parts[1],
              parts.length > 2 ? parts[2] : '',
            );
          })(),
    ];
  }

  Future<String> currentBranch(String dir) async {
    final result = await _git(dir, ['branch', '--show-current']);
    return result.out.trim();
  }

  Future<void> commit(String dir, String message) async {
    await _git(dir, ['add', '-A']);
    await _git(dir, ['commit', '-m', message]);
  }
}
