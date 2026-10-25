import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunset/app.dart';
import 'package:sunset/core/fs.dart';
import 'package:sunset/models/app_update.dart';
import 'package:sunset/state/app_state.dart';
import 'package:sunset/ui/pages/dashboard_page.dart';
import 'package:sunset/ui/pages/settings_page.dart';
import 'package:sunset/ui/shell/title_bar.dart';

import 'fakes.dart';

void main() {
  testWidgets('app shell navigates between dashboard and settings',
      (tester) async {
    final state = await testState();
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      AppScope(state: state, child: const SunsetApp()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DashboardPage), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardPage), findsOneWidget);
  });

  testWidgets('narrow layout uses a drawer', (tester) async {
    final state = await testState();
    tester.view.physicalSize = const Size(500, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      AppScope(state: state, child: const SunsetApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets('traffic lights call window actions', (tester) async {
    final actions = FakeWindowActions();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTitleBar(title: 'T', windowActions: actions),
        ),
      ),
    );
    expect(find.text('T'), findsOneWidget);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(
      find.byKey(const Key('titlebar.close')),
    ));
    await tester.pump();
    await tester.tap(find.byKey(const Key('titlebar.close')));
    await tester.tap(find.byKey(const Key('titlebar.minimize')));
    await tester.tap(find.byKey(const Key('titlebar.maximize')));
    await tester.pump();
    expect(actions.closed, 1);
    expect(actions.minimized, 1);
    expect(actions.maximized, 1);
    await mouse.moveTo(const Offset(0, 0));
    await tester.pump();
  });

  testWidgets('title bar double tap and drag', (tester) async {
    final actions = FakeWindowActions();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTitleBar(title: 'T', windowActions: actions),
        ),
      ),
    );
    await tester.drag(find.text('T'), const Offset(60, 0));
    await tester.pump();
    expect(actions.dragged, greaterThan(0));
    await tester.tap(find.text('T'));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(find.text('T'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(actions.maximized, greaterThan(0));
  });

  testWidgets('title bar without controls', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppTitleBar(title: 'X', showControls: false)),
      ),
    );
    expect(find.byKey(const Key('titlebar.close')), findsNothing);
  });

  testWidgets('dashboard shows empty state and new project dialog',
      (tester) async {
    final fs = MemFs();
    String? picked;
    final state = await testState(
      fs: fs,
      pickDir: () async => picked,
    );
    await pumpPage(tester, state, const DashboardPage(),
        size: const Size(1100, 800));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dashboard.new')), findsOneWidget);

    await tester.tap(find.byKey(const Key('dashboard.new')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('dashboard.new')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('dashboard.projectName')),
      'My App',
    );
    await tester.tap(find.byKey(const Key('dashboard.createConfirm')));
    await tester.pumpAndSettle();
    // no directory picked -> snackbar
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    picked = '/base';
    await tester.tap(find.byKey(const Key('dashboard.new')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('dashboard.projectName')),
      'My App',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(state.editor, isNotNull);
    expect(state.editor!.project.name, 'My App');
  });

  testWidgets('dashboard lists projects, opens and removes them',
      (tester) async {
    final fs = MemFs();
    final state = await testState(fs: fs);
    await state.createProject('/one', 'One');
    state.closeProject();
    await state.createProject('/two', 'Two');
    state.closeProject();
    await pumpPage(tester, state, const DashboardPage(),
        size: const Size(1100, 800));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    await tester.tap(find.byKey(const Key('project.One')));
    await tester.pumpAndSettle();
    expect(state.editor, isNotNull);
    expect(state.editor!.project.name, 'One');
    state.closeProject();
    await tester.tap(find.byKey(const Key('remove.One')));
    await tester.pumpAndSettle();
    expect(state.registry.entries.single.name, 'Two');
  });

  testWidgets('import project via picker', (tester) async {
    final fs = MemFs();
    await fs.write('/ext/pubspec.yaml',
        'name: ext\ndependencies:\n  flutter:\n    sdk: flutter\n');
    await fs.write('/ext/lib/main.dart', '');
    var pick = '/ext';
    final state = await testState(fs: fs, pickDir: () async => pick);
    await pumpPage(tester, state, const DashboardPage(),
        size: const Size(1100, 800));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dashboard.import')));
    await tester.pumpAndSettle();
    expect(state.editor!.project.imported, isTrue);
    state.closeProject();
    pick = '/missing';
    await tester.tap(find.byKey(const Key('dashboard.import')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('settings page edits theme accent language and updates',
      (tester) async {
    final launches = <Uri>[];
    final checker = FakeVersionChecker()
      ..result = const AppUpdate(
        currentVersion: '1.0.0',
        latestVersion: '2.0.0',
        updateAvailable: true,
        releaseUrl: 'https://example.com/r',
      );
    final state = await testState(
      versionChecker: checker,
      launches: launches,
    );
    await pumpPage(tester, state, const SettingsPage(),
        size: const Size(1100, 1000));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings.theme')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OLED').last);
    await tester.pumpAndSettle();
    expect(state.settings.theme.name, 'oled');

    await tester.tap(find.byKey(const Key('settings.accent.ff8a4fff')));
    await tester.pumpAndSettle();
    expect(state.settings.accentColor, 0xFF8A4FFF);

    await tester.tap(find.byKey(const Key('settings.language')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский').last);
    await tester.pumpAndSettle();
    expect(state.settings.locale, const Locale('ru'));

    await tester.tap(find.byKey(const Key('settings.checkUpdates')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings.getUpdate')), findsOneWidget);
    await tester.tap(find.byKey(const Key('settings.getUpdate')));
    expect(launches.single.toString(), 'https://example.com/r');

    await tester.tap(find.byKey(const Key('settings.releases')));
    expect(launches.last.toString(), contains('/releases'));
    await tester.tap(find.byKey(const Key('settings.source')));
    expect(launches.last.toString(), contains('gitlab.com'));

    final failing = FakeVersionChecker()..error = Exception('x');
    final state2 = await testState(versionChecker: failing);
    await pumpPage(tester, state2, const SettingsPage(),
        size: const Size(1100, 1000));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.checkUpdates')));
    await tester.pumpAndSettle();
  });

  testWidgets('project open replaces shell body and back restores it',
      (tester) async {
    final fs = MemFs();
    final state = await testState(fs: fs);
    await state.createProject('/p', 'Proj');
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      AppScope(state: state, child: const SunsetApp()),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor.back')), findsOneWidget);
    await tester.tap(find.byKey(const Key('editor.back')));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardPage), findsOneWidget);
  });

  testWidgets('isDesktopPlatform flag is readable', (tester) async {
    expect(isDesktopPlatform, isA<bool>());
  });
}
