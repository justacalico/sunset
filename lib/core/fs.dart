abstract class Fs {
  Future<String?> read(String path);
  Future<void> write(String path, String contents);
  Future<bool> exists(String path);
  Future<bool> isDir(String path);
  Future<List<String>> list(String dir);
  Future<void> delete(String path);
}

class MemFs implements Fs {
  final Map<String, String> files = {};
  final Set<String> dirs = {'/'};

  String _normalize(String path) {
    var p = path.replaceAll('\\', '/');
    while (p.contains('//')) {
      p = p.replaceAll('//', '/');
    }
    if (p.length > 1 && p.endsWith('/')) p = p.substring(0, p.length - 1);
    return p;
  }

  void _ensureParents(String path) {
    final parts = _normalize(path).split('/');
    var current = '';
    for (var i = 0; i < parts.length - 1; i++) {
      if (parts[i].isEmpty) continue;
      current = '$current/${parts[i]}';
      dirs.add(current);
    }
  }

  @override
  Future<String?> read(String path) async => files[_normalize(path)];

  @override
  Future<void> write(String path, String contents) async {
    _ensureParents(path);
    files[_normalize(path)] = contents;
  }

  @override
  Future<bool> exists(String path) async {
    final p = _normalize(path);
    return files.containsKey(p) || dirs.contains(p);
  }

  @override
  Future<bool> isDir(String path) async => dirs.contains(_normalize(path));

  @override
  Future<List<String>> list(String dir) async {
    final prefix = '${_normalize(dir)}/';
    final result = <String>{};
    for (final path in files.keys) {
      if (path.startsWith(prefix)) result.add(path.substring(prefix.length));
    }
    for (final path in dirs) {
      if (path.startsWith(prefix)) {
        result.add('${path.substring(prefix.length)}/');
      }
    }
    return result.toList()..sort();
  }

  @override
  Future<void> delete(String path) async {
    final p = _normalize(path);
    files.remove(p);
    final prefix = '$p/';
    files.removeWhere((k, _) => k.startsWith(prefix));
    dirs.removeWhere((d) => d == p || d.startsWith(prefix));
  }
}
