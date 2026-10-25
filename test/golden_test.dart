import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunset/core/fs.dart';
import 'package:sunset/core/model.dart';
import 'package:sunset/l10n/app_localizations.dart';
import 'package:sunset/state/app_state.dart';
import 'package:sunset/state/editor_state.dart';
import 'package:sunset/state/project_registry.dart';
import 'package:sunset/ui/pages/dashboard_page.dart';
import 'package:sunset/ui/pages/project_page.dart';
import 'package:sunset/ui/pages/settings_page.dart';
import 'package:sunset/ui/shell/app_shell.dart';

import 'fakes.dart';

Widget wrap(AppState state, Widget child, {Locale? locale}) => AppScope(
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
    theme: ThemeData(
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFF3813F),
        brightness: Brightness.dark,
      ),
    ),
    home: child,
  ),
);

Future<void> snap(
  WidgetTester tester,
  String name,
  Widget child, {
  Size size = const Size(1200, 860),
  Locale? locale,
  AppState? state,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    wrap(state ?? await testState(), child, locale: locale),
  );
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

SunsetProject goldenProject() {
  final p = testProject();
  final screen = p.screens.first;
  final col = p.addWidget(screen.id, 'column').node!;
  col.props['spacing'] = 12.0;
  final title = p.addWidget(screen.id, 'text', parentId: col.id).node!;
  title.props['text'] = 'Welcome';
  title.props['size'] = 28.0;
  title.props['bold'] = true;
  final sub = p.addWidget(screen.id, 'text', parentId: col.id).node!;
  sub.props['textKey'] = 'hello';
  sub.props['size'] = 15.0;
  final row = p.addWidget(screen.id, 'row', parentId: col.id).node!;
  row.props['spacing'] = 8.0;
  final b1 = p.addWidget(screen.id, 'button', parentId: row.id).node!;
  b1.props['label'] = 'Get started';
  b1.props['icon'] = 'arrow_forward';
  final b2 = p.addWidget(screen.id, 'button', parentId: row.id).node!;
  b2.props['label'] = 'Docs';
  b2.props['style'] = 'outlined';
  final card = p.addWidget(screen.id, 'card', parentId: col.id).node!;
  final field = p.addWidget(screen.id, 'textField', parentId: card.id).node!;
  field.props['hint'] = 'Your email';
  field.props['label'] = 'Sign up';
  final sw = p.addWidget(screen.id, 'switcher', parentId: col.id).node!;
  sw.props['label'] = 'Newsletter';
  return p;
}

void main() {
  testWidgets('app shell golden', (tester) async {
    await snap(tester, 'app_shell', const AppShell());
  });

  testWidgets('dashboard golden', (tester) async {
    final state = await testState();
    await state.registry.add(
      const ProjectEntry(name: 'Demo app', path: '/home/u/demo'),
      state.prefs,
    );
    await state.registry.add(
      const ProjectEntry(
        name: 'Vibecoded',
        path: '/home/u/vibe',
        imported: true,
      ),
      state.prefs,
    );
    await snap(tester, 'dashboard', const DashboardPage(), state: state);
  });

  testWidgets('dashboard empty golden', (tester) async {
    await snap(tester, 'dashboard_empty', const DashboardPage());
  });

  testWidgets('editor golden', (tester) async {
    final fs = MemFs();
    final state = await testState(fs: fs);
    final project = goldenProject();
    final editor = EditorState(
      project: project,
      dir: '/p',
      fs: fs,
      gitRun: FakeGit().run,
    );
    await tester.pumpWidget(
      wrap(state, Scaffold(body: ProjectPage(editor: editor))),
    );
    tester.view.physicalSize = const Size(1500, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp).first,
      matchesGoldenFile('goldens/editor.png'),
    );
  });

  testWidgets('settings page golden', (tester) async {
    await snap(
      tester,
      'settings_page',
      const Scaffold(body: SettingsPage()),
      size: const Size(1100, 900),
    );
  });

  testWidgets('editor zh golden', (tester) async {
    final fs = MemFs();
    final state = await testState();
    await state.settings.setLocale(const Locale('zh', 'Hans'), state.prefs);
    final editor = EditorState(
      project: goldenProject(),
      dir: '/p',
      fs: fs,
      gitRun: FakeGit().run,
    );
    tester.view.physicalSize = const Size(1500, 950);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      wrap(
        state,
        Scaffold(body: ProjectPage(editor: editor)),
        locale: const Locale('zh', 'Hans'),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp).first,
      matchesGoldenFile('goldens/editor_zh.png'),
    );
  });
}
