import 'dart:convert';

import 'catalog.dart';

class WidgetNode {
  final String id;
  String type;
  final Map<String, Object?> props;
  final List<WidgetNode> children;

  WidgetNode({
    required this.id,
    required this.type,
    Map<String, Object?>? props,
    List<WidgetNode>? children,
  }) : props = props ?? {},
       children = children ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'props': props,
    'children': [for (final c in children) c.toJson()],
  };

  factory WidgetNode.fromJson(Map<String, dynamic> json) => WidgetNode(
    id: json['id'] as String,
    type: json['type'] as String,
    props: Map<String, Object?>.from(json['props'] as Map? ?? {}),
    children: [
      for (final c in json['children'] as List? ?? const [])
        WidgetNode.fromJson(Map<String, dynamic>.from(c as Map)),
    ],
  );

  WidgetNode clone() =>
      WidgetNode.fromJson(jsonDecode(jsonEncode(toJson())) as Map<String, dynamic>);

  WidgetNode? find(String id) {
    if (this.id == id) return this;
    for (final child in children) {
      final hit = child.find(id);
      if (hit != null) return hit;
    }
    return null;
  }

  WidgetNode? parentOf(String id) {
    for (final child in children) {
      if (child.id == id) return this;
      final hit = child.parentOf(id);
      if (hit != null) return hit;
    }
    return null;
  }

  Iterable<WidgetNode> walk() sync* {
    yield this;
    for (final child in children) {
      yield* child.walk();
    }
  }

  bool detach(String id) {
    for (var i = 0; i < children.length; i++) {
      if (children[i].id == id) {
        children.removeAt(i);
        return true;
      }
      if (children[i].detach(id)) return true;
    }
    return false;
  }
}

class ProjectScreen {
  final String id;
  String name;
  bool responsive;
  final WidgetNode root;

  ProjectScreen({
    required this.id,
    required this.name,
    required this.root,
    this.responsive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'responsive': responsive,
    'root': root.toJson(),
  };

  factory ProjectScreen.fromJson(Map<String, dynamic> json) => ProjectScreen(
    id: json['id'] as String,
    name: json['name'] as String,
    responsive: json['responsive'] as bool? ?? true,
    root: WidgetNode.fromJson(
      Map<String, dynamic>.from(json['root'] as Map),
    ),
  );
}

enum ThemeBrightness { system, light, dark }

class ThemeSpec {
  int seedColor;
  ThemeBrightness brightness;
  double radius;

  ThemeSpec({
    this.seedColor = 0xFFF3813F,
    this.brightness = ThemeBrightness.system,
    this.radius = 12,
  });

  Map<String, dynamic> toJson() => {
    'seedColor': seedColor,
    'brightness': brightness.name,
    'radius': radius,
  };

  factory ThemeSpec.fromJson(Map<String, dynamic> json) => ThemeSpec(
    seedColor: json['seedColor'] as int? ?? 0xFFF3813F,
    brightness:
        ThemeBrightness.values.asNameMap()[json['brightness'] as String?] ??
        ThemeBrightness.system,
    radius: (json['radius'] as num?)?.toDouble() ?? 12,
  );
}

class SunsetProject {
  String name;
  String packageName;
  String description;
  ThemeSpec theme;
  final List<String> locales;
  final Map<String, Map<String, String>> messages;
  final List<ProjectScreen> screens;
  bool imported;
  List<String> importedFiles;
  int idCounter;

  SunsetProject({
    required this.name,
    required this.packageName,
    this.description = '',
    ThemeSpec? theme,
    List<String>? locales,
    Map<String, Map<String, String>>? messages,
    List<ProjectScreen>? screens,
    this.imported = false,
    List<String>? importedFiles,
    this.idCounter = 0,
  }) : theme = theme ?? ThemeSpec(),
       locales = locales ?? ['en_GB'],
       messages = messages ?? {},
       screens = screens ?? [],
       importedFiles = importedFiles ?? [];

  factory SunsetProject.create(String name, {String? packageName}) {
    final project = SunsetProject(
      name: name,
      packageName:
          packageName ?? 'com.example.${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}',
      description: 'A $name app built with Sunset.',
    );
    project.addScreen('Home');
    return project;
  }

  String _nextId(String prefix) => '$prefix${++idCounter}';

  Map<String, dynamic> toJson() => {
    'name': name,
    'packageName': packageName,
    'description': description,
    'theme': theme.toJson(),
    'locales': locales,
    'messages': messages,
    'screens': [for (final s in screens) s.toJson()],
    'imported': imported,
    'importedFiles': importedFiles,
    'idCounter': idCounter,
  };

  factory SunsetProject.fromJson(Map<String, dynamic> json) => SunsetProject(
    name: json['name'] as String,
    packageName: json['packageName'] as String? ?? 'com.example.app',
    description: json['description'] as String? ?? '',
    theme: ThemeSpec.fromJson(
      Map<String, dynamic>.from(json['theme'] as Map? ?? {}),
    ),
    locales: [for (final l in json['locales'] as List? ?? const []) '$l'],
    messages: {
      for (final e in (json['messages'] as Map? ?? {}).entries)
        e.key as String: {
          for (final m in (e.value as Map).entries) m.key as String: '${m.value}',
        },
    },
    screens: [
      for (final s in json['screens'] as List? ?? const [])
        ProjectScreen.fromJson(Map<String, dynamic>.from(s as Map)),
    ],
    imported: json['imported'] as bool? ?? false,
    importedFiles: [
      for (final f in json['importedFiles'] as List? ?? const []) '$f',
    ],
    idCounter: json['idCounter'] as int? ?? 0,
  );

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory SunsetProject.decode(String source) =>
      SunsetProject.fromJson(jsonDecode(source) as Map<String, dynamic>);

  ProjectScreen? screenById(String id) {
    for (final s in screens) {
      if (s.id == id) return s;
    }
    return null;
  }

  ProjectScreen addScreen(String name) {
    final root = WidgetNode(id: _nextId('w'), type: 'scaffold', props: {
      'title': name,
      'showAppBar': true,
    });
    final screen = ProjectScreen(id: _nextId('s'), name: name, root: root);
    screens.add(screen);
    return screen;
  }

  bool removeScreen(String id) {
    if (screens.length <= 1) return false;
    final before = screens.length;
    screens.removeWhere((s) => s.id == id);
    return screens.length != before;
  }

  bool renameScreen(String id, String name) {
    final screen = screenById(id);
    if (screen == null) return false;
    screen.name = name;
    return true;
  }

  ({WidgetNode? node, String? error}) addWidget(
    String screenId,
    String type, {
    String? parentId,
    int? index,
  }) {
    final screen = screenById(screenId);
    if (screen == null) return (node: null, error: 'screen not found');
    final parent = parentId == null ? screen.root : screen.root.find(parentId);
    if (parent == null) return (node: null, error: 'parent not found');
    if ((type == 'expanded' || type == 'spacer') &&
        parent.type != 'column' &&
        parent.type != 'row') {
      return (node: null, error: 'needs a column or row parent');
    }
    final cap = widgetDef(parent.type)?.maxChildren ?? -1;
    if (cap >= 0 && parent.children.length >= cap) {
      return (node: null, error: 'parent is full');
    }
    final node = WidgetNode(id: _nextId('w'), type: type);
    final at = index == null
        ? parent.children.length
        : index.clamp(0, parent.children.length);
    parent.children.insert(at, node);
    return (node: node, error: null);
  }

  bool removeWidget(String screenId, String nodeId) {
    final screen = screenById(screenId);
    if (screen == null || screen.root.id == nodeId) return false;
    return screen.root.detach(nodeId);
  }

  bool moveWidget(
    String screenId,
    String nodeId, {
    String? parentId,
    int? index,
  }) {
    final screen = screenById(screenId);
    if (screen == null || screen.root.id == nodeId) return false;
    final node = screen.root.find(nodeId);
    final parent = parentId == null
        ? screen.root.parentOf(nodeId)
        : screen.root.find(parentId);
    if (node == null || parent == null) return false;
    if (node.find(parent.id) != null) return false;
    screen.root.detach(nodeId);
    final at = index == null
        ? parent.children.length
        : index.clamp(0, parent.children.length);
    parent.children.insert(at, node);
    return true;
  }

  bool setProp(String screenId, String nodeId, String prop, Object? value) {
    final screen = screenById(screenId);
    final node = screen?.root.find(nodeId);
    if (node == null) return false;
    node.props[prop] = value;
    return true;
  }

  void addLocale(String tag) {
    if (!locales.contains(tag)) locales.add(tag);
  }

  bool removeLocale(String tag) {
    if (locales.length <= 1) return false;
    final removed = locales.remove(tag);
    if (removed) {
      for (final entry in messages.values) {
        entry.remove(tag);
      }
    }
    return removed;
  }

  void setMessage(String key, String locale, String text) {
    (messages[key] ??= {})[locale] = text;
  }

  bool removeMessage(String key) => messages.remove(key) != null;

  String? message(String key, String locale) =>
      messages[key]?[locale] ??
      messages[key]?[locales.isEmpty ? 'en_GB' : locales.first];
}
