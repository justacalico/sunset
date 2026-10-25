import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/fs.dart';
import '../core/importer.dart';
import '../core/git_service.dart';
import '../core/store.dart';
import '../models/app_update.dart';
import '../services/launcher.dart';
import '../services/version_checker.dart';
import '../services/window_actions.dart';
import 'editor_state.dart';
import 'project_registry.dart';
import 'settings_store.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences prefs;
  final WindowActions? windowActions;
  final SettingsStore settings;
  final ProjectRegistry registry;
  final UrlLaunch launch;
  final Future<PackageInfo> Function() packageInfo;
  final Fs fs;
  final ProcRun gitRun;
  final Future<String?> Function()? pickDir;
  final bool isWeb;

  int _tabIndex = 0;
  EditorState? _editor;
  AppUpdate? _update;
  Future<AppUpdate?>? _updateCheck;
  final VersionChecker? _versionChecker;

  AppState({
    required this.prefs,
    required this.settings,
    required this.registry,
    required this.launch,
    required this.packageInfo,
    required this.fs,
    required this.gitRun,
    this.windowActions,
    this.pickDir,
    this.isWeb = false,
    this._versionChecker,
  });

  int get tabIndex => _tabIndex;
  EditorState? get editor => _editor;

  void selectTab(int index) {
    if (index == _tabIndex) return;
    _tabIndex = index;
    notifyListeners();
  }

  Future<void> openProject(String dir) async {
    final project = await ProjectStore(fs).load(dir);
    _editor = EditorState(project: project, dir: dir, fs: fs, gitRun: gitRun);
    await registry.add(
      ProjectEntry(
        name: project.name,
        path: dir,
        imported: project.imported,
        openedAt: DateTime.now().toIso8601String(),
      ),
      prefs,
    );
    notifyListeners();
  }

  void closeProject() {
    _editor = null;
    notifyListeners();
  }

  Future<void> createProject(
    String dir,
    String name, {
    String? packageName,
  }) async {
    await ProjectStore(fs).create(dir, name: name, packageName: packageName);
    await openProject(dir);
  }

  Future<void> importProject(String dir) async {
    await importFlutterProject(fs, dir);
    await openProject(dir);
  }

  AppUpdate? get update => _update;

  Future<AppUpdate?> checkForUpdate() {
    final existing = _updateCheck;
    if (existing != null) return existing;
    return _updateCheck = _runUpdateCheck().whenComplete(
      () => _updateCheck = null,
    );
  }

  Future<AppUpdate?> _runUpdateCheck() async {
    try {
      final checker = _versionChecker ?? VersionChecker();
      final info = await packageInfo();
      final update = await checker.check(info.version);
      if (_update != update) {
        _update = update;
        notifyListeners();
      }
      return update;
    } catch (_) {
      return null;
    }
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<AppScope>()!.widget
              as AppScope)
          .notifier!;
}
