import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunset/core/fs.dart';
import 'package:sunset/core/git_service.dart';
import 'package:sunset/core/model.dart';
import 'package:sunset/l10n/app_localizations.dart';
import 'package:sunset/models/app_update.dart';
import 'package:sunset/services/version_checker.dart';
import 'package:sunset/services/window_actions.dart';
import 'package:sunset/state/app_state.dart';
import 'package:sunset/state/project_registry.dart';
import 'package:sunset/state/settings_store.dart';

const testPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

final testPng = Uint8List.fromList(
  const Base64Decoder().convert(testPngBase64),
);

class FakeWindowActions implements WindowActions {
  int minimized = 0;
  int maximized = 0;
  int closed = 0;
  int dragged = 0;

  @override
  Future<void> minimize() async => minimized++;

  @override
  Future<void> toggleMaximize() async => maximized++;

  @override
  Future<void> close() async => closed++;

  @override
  Future<void> startDrag() async => dragged++;
}

class FakeVersionChecker extends VersionChecker {
  AppUpdate? result;
  Object? error;
  int calls = 0;
  Completer<void>? gate;

  @override
  Future<AppUpdate> check(String currentVersion) async {
    calls++;
    await gate?.future;
    if (error != null) throw error!;
    return result ?? AppUpdate(currentVersion: currentVersion);
  }
}

class FakeGit {
  final Map<String, List<ProcResult>> queue = {};
  final List<List<String>> calls = [];
  bool repo = false;
  List<String> files = const [];
  List<String> commits = const [];

  Future<ProcResult> run(List<String> args, String cwd) async {
    calls.add(args);
    final key = args.first;
    final queued = queue[key];
    if (queued != null && queued.isNotEmpty) return queued.removeAt(0);
    switch (key) {
      case 'rev-parse':
        return ProcResult(repo ? 0 : 128, repo ? 'true' : '', 'not a repo');
      case 'init':
        repo = true;
        return const ProcResult(0, '', '');
      case 'status':
        return ProcResult(0, files.join('\n'), '');
      case 'log':
        return ProcResult(0, commits.join('\n'), '');
      case 'branch':
        return const ProcResult(0, 'main\n', '');
      case 'add' || 'commit':
        return const ProcResult(0, '', '');
    }
    return const ProcResult(0, '', '');
  }
}

SunsetProject testProject({String name = 'Demo'}) {
  final project = SunsetProject.create(name);
  project.addLocale('zh_Hans');
  project.setMessage('hello', 'en_GB', 'Hello there');
  project.setMessage('hello', 'zh_Hans', '你好');
  return project;
}

Future<AppState> testState({
  Map<String, Object>? prefs,
  Fs? fs,
  ProcRun? gitRun,
  SettingsStore? settings,
  ProjectRegistry? registry,
  FakeVersionChecker? versionChecker,
  List<Uri>? launches,
  Future<String?> Function()? pickDir,
  String version = '1.0.0',
  bool isWeb = false,
}) async {
  SharedPreferences.setMockInitialValues(prefs ?? {});
  final shared = await SharedPreferences.getInstance();
  return AppState(
    prefs: shared,
    settings: settings ?? await SettingsStore.load(shared),
    registry: registry ?? await ProjectRegistry.load(shared),
    launch: (uri) async {
      launches?.add(uri);
      return true;
    },
    packageInfo: () async => PackageInfo(
      appName: 'sunset',
      packageName: 'gitlab.httpanimations.sunset',
      version: version,
      buildNumber: '1',
    ),
    fs: fs ?? MemFs(),
    gitRun: gitRun ?? FakeGit().run,
    windowActions: FakeWindowActions(),
    pickDir: pickDir,
    isWeb: isWeb,
    versionChecker: versionChecker,
  );
}

Future<void> pumpPage(
  WidgetTester tester,
  AppState state,
  Widget child, {
  Size? size,
  Locale? locale,
  Brightness brightness = Brightness.dark,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(fontFamily: 'Inter', brightness: brightness),
        home: Scaffold(body: child),
      ),
    ),
  );
}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeRequest();
}

class _FakeRequest extends Fake implements HttpClientRequest {
  final _response = _FakeResponse();

  @override
  Future<HttpClientResponse> close() async => _response;

  @override
  Future<HttpClientResponse> get done async => _response;
}

class _FakeResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => testPng.length;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(testPng).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
}

http.Client mockHttp(Map<String, http.Response Function(Uri)> routes) =>
    MockClient((request) async {
      final key = '${request.method} ${request.url.path}';
      final handler = routes[key] ?? routes['${request.method} *'];
      if (handler == null) {
        return http.Response('not found', 404);
      }
      return handler(request.url);
    });
