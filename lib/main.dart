import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/platform/platform_pick.dart';
import 'services/launcher.dart';
import 'services/window_actions_impl.dart';
import 'state/app_state.dart';
import 'state/project_registry.dart';
import 'state/settings_store.dart';
import 'ui/shell/title_bar.dart' show isDesktopPlatform;

// coverage:ignore-start
Future<void> _initWindow() async {
  await windowManager.ensureInitialized();
  const options = WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
// coverage:ignore-end

Future<AppState> createAppState(SharedPreferences prefs) async {
  final settings = await SettingsStore.load(prefs);
  final registry = await ProjectRegistry.load(prefs);
  return AppState(
    prefs: prefs,
    settings: settings,
    registry: registry,
    launch: defaultLaunch,
    packageInfo: PackageInfo.fromPlatform,
    fs: defaultFs(),
    gitRun: defaultGitRun(),
    windowActions: isDesktopPlatform ? WindowManagerActions() : null,
    pickDir: kIsWeb ? null : pickProjectDir, // coverage:ignore-line
    isWeb: kIsWeb,
  );
}

// coverage:ignore-start
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isDesktopPlatform) {
    await _initWindow();
  }
  final prefs = await SharedPreferences.getInstance();
  final state = await createAppState(prefs);
  runApp(AppScope(state: state, child: const SunsetApp()));
}
// coverage:ignore-end
