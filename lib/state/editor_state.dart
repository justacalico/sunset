import 'package:flutter/widgets.dart';

import '../core/catalog.dart';
import '../core/codegen.dart';
import '../core/fs.dart';
import '../core/git_service.dart';
import '../core/model.dart';
import '../core/store.dart';

enum DevicePreset { phone, tablet, desktop }

class EditorState extends ChangeNotifier {
  SunsetProject project;
  final String dir;
  final Fs fs;
  final GitService git;

  String _screenId;
  String? _selectedId;
  int leftTab = 0;
  int rightTab = 0;
  DevicePreset device = DevicePreset.phone;
  bool previewDark = false;
  bool dirty = false;

  final List<String> _undo = [];

  List<GitFile> gitFiles = const [];
  List<GitCommit> gitLog = const [];
  String gitBranch = '';
  bool gitRepo = false;
  String? gitError;
  bool gitBusy = false;

  EditorState({
    required this.project,
    required this.dir,
    required this.fs,
    required ProcRun gitRun,
  }) : git = GitService(gitRun),
       _screenId = project.screens.first.id;

  ProjectScreen get screen => project.screenById(_screenId)!;
  String? get selectedId => _selectedId;
  WidgetNode? get selected =>
      _selectedId == null ? null : screen.root.find(_selectedId!);
  bool get canUndo => _undo.isNotEmpty;
  String get baseLocale =>
      project.locales.isEmpty ? 'en_GB' : project.locales.first;

  void selectScreen(String id) {
    if (_screenId == id) return;
    _screenId = id;
    _selectedId = null;
    notifyListeners();
  }

  void select(String? nodeId) {
    _selectedId = nodeId;
    notifyListeners();
  }

  void setLeftTab(int i) {
    leftTab = i;
    notifyListeners();
  }

  void setRightTab(int i) {
    rightTab = i;
    notifyListeners();
  }

  void setDevice(DevicePreset preset) {
    device = preset;
    notifyListeners();
  }

  void togglePreviewDark() {
    previewDark = !previewDark;
    notifyListeners();
  }

  void _mutate(void Function() change) {
    _undo.add(project.encode());
    change();
    dirty = true;
    notifyListeners();
  }

  bool _acceptsChildren(WidgetNode node) {
    final def = widgetDef(node.type);
    if (def == null) return false;
    return def.maxChildren < 0 || node.children.length < def.maxChildren;
  }

  String? _defaultParentId({String? type}) {
    final flex = type == 'expanded' || type == 'spacer';
    bool ok(WidgetNode n) =>
        _acceptsChildren(n) && (!flex || n.type == 'column' || n.type == 'row');
    final root = screen.root;
    final selected = this.selected;
    if (selected != null && ok(selected)) return selected.id;
    if (selected != null) {
      final parent = root.parentOf(selected.id);
      if (parent != null && ok(parent)) return parent.id;
    }
    if (ok(root)) return root.id;
    for (final node in root.walk()) {
      final def = widgetDef(node.type);
      if (def != null && def.maxChildren < 0 && ok(node)) return node.id;
    }
    return null;
  }

  WidgetNode? addWidget(String type, {String? parentId}) {
    final def = widgetDef(type);
    if (def == null) return null;
    WidgetNode? created;
    _mutate(() {
      final result = project.addWidget(
        screen.id,
        type,
        parentId: parentId ?? _defaultParentId(type: type),
      );
      created = result.node;
      if (created != null) {
        for (final prop in def.props) {
          created!.props[prop.name] = prop.value;
        }
      }
    });
    if (created != null) _selectedId = created!.id;
    return created;
  }

  void removeWidget(String nodeId) {
    _mutate(() {
      project.removeWidget(screen.id, nodeId);
      if (_selectedId == nodeId) _selectedId = null;
    });
  }

  void moveWidget(String nodeId, String parentId, int index) {
    _mutate(
      () => project.moveWidget(
        screen.id,
        nodeId,
        parentId: parentId,
        index: index,
      ),
    );
  }

  void reorder(String nodeId, int delta) {
    final parent = screen.root.parentOf(nodeId);
    if (parent == null) return;
    final index = parent.children.indexWhere((c) => c.id == nodeId);
    final target = index + delta;
    if (index < 0 || target < 0 || target >= parent.children.length) return;
    _mutate(() {
      project.moveWidget(screen.id, nodeId, index: target);
    });
  }

  void setProp(String nodeId, String prop, Object? value) {
    _mutate(() => project.setProp(screen.id, nodeId, prop, value));
  }

  void addScreen(String name) {
    _mutate(() {
      final screen = project.addScreen(name);
      _screenId = screen.id;
      _selectedId = null;
    });
  }

  void renameScreen(String id, String name) =>
      _mutate(() => project.renameScreen(id, name));

  bool removeScreen(String id) {
    if (project.screens.length <= 1) return false;
    _mutate(() {
      project.removeScreen(id);
      if (_screenId == id) {
        _screenId = project.screens.first.id;
        _selectedId = null;
      }
    });
    return true;
  }

  void setResponsive(bool value) => _mutate(() => screen.responsive = value);

  void setSeedColor(int color) =>
      _mutate(() => project.theme.seedColor = color);

  void setBrightness(ThemeBrightness mode) =>
      _mutate(() => project.theme.brightness = mode);

  void setRadius(double radius) => _mutate(() => project.theme.radius = radius);

  void setPackageName(String value) =>
      _mutate(() => project.packageName = value);

  void addLocale(String tag) => _mutate(() => project.addLocale(tag));

  void removeLocale(String tag) => _mutate(() => project.removeLocale(tag));

  void setMessage(String key, String locale, String text) =>
      _mutate(() => project.setMessage(key, locale, text));

  void removeMessage(String key) => _mutate(() => project.removeMessage(key));

  void undo() {
    if (_undo.isEmpty) return;
    final snapshot = _undo.removeLast();
    project = SunsetProject.decode(snapshot);
    if (project.screenById(_screenId) == null) {
      _screenId = project.screens.first.id;
    }
    if (_selectedId != null && screen.root.find(_selectedId!) == null) {
      _selectedId = null;
    }
    dirty = true;
    notifyListeners();
  }

  Future<void> save() async {
    await ProjectStore(fs).save(dir, project);
    dirty = false;
    notifyListeners();
  }

  Future<int> export() async {
    final files = generateProject(project);
    for (final entry in files.entries) {
      await fs.write('$dir/${entry.key}', entry.value);
    }
    return files.length;
  }

  Future<void> gitRefresh() async {
    gitBusy = true;
    gitError = null;
    notifyListeners();
    try {
      gitRepo = await git.isRepo(dir);
      if (gitRepo) {
        gitFiles = await git.status(dir);
        gitLog = await git.log(dir);
        gitBranch = await git.currentBranch(dir);
      }
    } catch (e) {
      gitError = '$e';
    }
    gitBusy = false;
    notifyListeners();
  }

  Future<void> gitInit() async {
    gitBusy = true;
    gitError = null;
    notifyListeners();
    try {
      await git.init(dir);
      gitRepo = true;
      await gitRefresh();
    } catch (e) {
      gitError = '$e';
      gitBusy = false;
      notifyListeners();
    }
  }

  Future<void> gitCommit(String message) async {
    gitBusy = true;
    gitError = null;
    notifyListeners();
    try {
      await git.commit(dir, message);
      await gitRefresh();
    } catch (e) {
      gitError = '$e';
      gitBusy = false;
      notifyListeners();
    }
  }
}
