import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectEntry {
  final String name;
  final String path;
  final bool imported;
  final String openedAt;

  const ProjectEntry({
    required this.name,
    required this.path,
    this.imported = false,
    this.openedAt = '',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'imported': imported,
    'openedAt': openedAt,
  };

  factory ProjectEntry.fromJson(Map<String, dynamic> json) => ProjectEntry(
    name: json['name'] as String,
    path: json['path'] as String,
    imported: json['imported'] as bool? ?? false,
    openedAt: json['openedAt'] as String? ?? '',
  );
}

class ProjectRegistry extends ChangeNotifier {
  static const _key = 'projects';

  List<ProjectEntry> _entries;

  ProjectRegistry([List<ProjectEntry>? entries])
    : _entries = entries ?? const [];

  static Future<ProjectRegistry> load(SharedPreferences prefs) async {
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return ProjectRegistry();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return ProjectRegistry();
      return ProjectRegistry([
        for (final e in decoded)
          if (e is Map)
            ProjectEntry.fromJson(Map<String, dynamic>.from(e)),
      ]);
    } catch (_) {
      return ProjectRegistry();
    }
  }

  List<ProjectEntry> get entries => List.unmodifiable(_entries);

  Future<void> _persist(SharedPreferences prefs) async {
    await prefs.setString(
      _key,
      jsonEncode([for (final e in _entries) e.toJson()]),
    );
  }

  Future<void> add(ProjectEntry entry, SharedPreferences prefs) async {
    _entries = [
      for (final e in _entries)
        if (e.path != entry.path) e,
      entry,
    ];
    notifyListeners();
    await _persist(prefs);
  }

  Future<void> remove(String path, SharedPreferences prefs) async {
    _entries = [for (final e in _entries) if (e.path != path) e];
    notifyListeners();
    await _persist(prefs);
  }

  ProjectEntry? byPath(String path) {
    for (final e in _entries) {
      if (e.path == path) return e;
    }
    return null;
  }
}
