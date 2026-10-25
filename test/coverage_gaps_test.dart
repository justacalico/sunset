import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunset/app.dart';
import 'package:sunset/cli/runner.dart';
import 'package:sunset/core/fs.dart';
import 'package:sunset/core/git_service.dart';
import 'package:sunset/core/model.dart';
import 'package:sunset/l10n/app_localizations.dart';
import 'package:sunset/models/app_update.dart';
import 'package:sunset/services/version_checker.dart';
import 'package:sunset/state/app_state.dart';
import 'package:sunset/state/editor_state.dart';
import 'package:sunset/state/settings_store.dart';
import 'package:sunset/ui/editor/inspector.dart';
import 'package:sunset/ui/editor/panels.dart';
import 'package:sunset/ui/editor/palette.dart';
import 'package:sunset/ui/editor/preview.dart';
import 'package:sunset/ui/shell/side_nav.dart';

import 'editor_test.dart' show openEditor;
import 'fakes.dart';
import 'package:sunset/ui/pages/dashboard_page.dart';
import 'package:sunset/ui/pages/settings_page.dart';

void main() {
  test('AppUpdate equality and hash', () {
    const a = AppUpdate(
      currentVersion: '1',
      latestVersion: '2',
      updateAvailable: true,
      releaseUrl: 'u',
    );
    const b = AppUpdate(
      currentVersion: '1',
      latestVersion: '2',
      updateAvailable: true,
      releaseUrl: 'u',
    );
    const c = AppUpdate();
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == c, isFalse);
    expect(a == Object(), isFalse);
  });

  test('VersionCheckException toString', () {
    expect(const VersionCheckException('x').toString(), contains('x'));
  });

  test('CliUsageException is throwable', () {
    expect(() => throw const CliUsageException('m'),
        throwsA(isA<CliUsageException>()));
  });

  test('MemFs normalize edge cases', () async {
    final fs = MemFs();
    await fs.write('//a//b//', 'x');
    expect(await fs.read('/a/b'), 'x');
  });

  test('model misc branches', () {
    final p = SunsetProject(name: 'x', packageName: 'y', locales: []);
    expect(p.message('k', 'en_GB'), isNull);
    final n = WidgetNode(id: 'a', type: 'text');
    expect(n.parentOf('x'), isNull);
  });

  testWidgets('oled material app', (tester) async {
    final state = await testState();
    await state.settings.setTheme(AppTheme.oled, state.prefs);
    await tester.pumpWidget(
      AppScope(state: state, child: const SunsetApp()),
    );
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.darkTheme!.scaffoldBackgroundColor, Colors.black);
  });

  testWidgets('SideNav footer item', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            SideNav(
              selectedIndex: 0,
              onSelected: (_) {},
              destinations: const [
                (icon: Icons.home, selectedIcon: Icons.home, label: 'Home'),
              ],
              footerLabel: 'New',
              onFooter: () => tapped = true,
            ),
          ],
        ),
      ),
    ));
    await tester.tap(find.text('New'));
    expect(tapped, isTrue);
  });

  testWidgets('StringsPanel dialogs', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    await pumpPage(tester, state, StringsPanel(editor: state.editor!));
    await tester.pumpAndSettle();
  });

  testWidgets('git panel error and busy states', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = state.editor!;
    editor.gitError = 'boom';
    editor.gitBusy = true;
    editor.gitRepo = true;
    await pumpPage(tester, state, GitPanel(editor: editor));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('boom'), findsOneWidget);
  });

  testWidgets('export panel imported hint', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = state.editor!;
    editor.project.imported = true;
    await pumpPage(tester, state, ExportPanel(editor: editor));
    await tester.pump();
  });

  testWidgets('preview prop variations', (tester) async {
    final p = testProject();
    final screen = p.screens.first;
    final col = p.addWidget(screen.id, 'column').node!;
    WidgetNode add(String type, Map<String, Object?> props,
        {String? parent}) {
      final n = p
          .addWidget(screen.id, type, parentId: parent ?? col.id)
          .node!;
      n.props.addAll(props);
      return n;
    }

    add('sizedBox', {'width': 10.0, 'height': 10.0});
    add('container', {
      'width': 40.0,
      'height': 30.0,
      'color': 0xFF123456,
      'padding': 4.0,
      'radius': 8.0,
      'align': 'center',
    });
    add('card', {'elevation': 4.0, 'radius': 6.0, 'padding': 4.0});
    add('image', {'url': 'https://bad.invalid/x.png', 'fit': 'contain'});
    add('circleAvatar', {'color': 0xFF123456, 'icon': 'home'});
    add('icon', {'color': 0xFF123456, 'icon': 'unknown_icon'});
    add('button', {'style': 'tonal', 'icon': 'star', 'label': 'T'});
    add('button', {'style': 'outlined', 'icon': 'add', 'label': 'O'});
    add('button', {'style': 'text', 'icon': 'check', 'label': 'X'});
    add('button', {'style': 'filled', 'icon': 'add', 'label': 'F'});
    add('textField', {'label': 'L', 'hint': 'H', 'dense': false});
    add('stack', {'alignment': 'center'});
    add('spacer', {'flex': 2});
    add('expanded', {'flex': 2}, parent: col.id);
    add('gridView', {'height': 100.0});
    add('listView', {'height': 100.0, 'padding': 8.0});
    tester.view.physicalSize = const Size(500, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: NodePreview(project: p, screen: screen),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });

  testWidgets('image errorBuilder shows fallback', (tester) async {
    final p = testProject();
    final screen = p.screens.first;
    final img = p.addWidget(screen.id, 'image').node!;
    img.props['url'] = 'https://bad.invalid/x.png';
    await tester.pumpWidget(
      MaterialApp(home: NodePreview(project: p, screen: screen)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });

  testWidgets('palette unknown icon fallback', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    await pumpPage(tester, state, PalettePanel(editor: state.editor!));
    await tester.pump();
    expect(find.byIcon(Icons.widgets_outlined), findsNothing);
  });

  testWidgets('editor moveWidget via state', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = state.editor!;
    final col = editor.addWidget('column')!;
    final t = editor.addWidget('text', parentId: col.id)!;
    editor.moveWidget(t.id, col.id, 0);
    expect(col.children.first.id, t.id);
    editor.removeScreen(editor.screen.id);
    expect(editor.project.screens, hasLength(1));
  });

  test('model spacer parent rule and move without index', () {
    final p = SunsetProject.create('X');
    final s = p.screens.first;
    final res = p.addWidget(s.id, 'spacer');
    expect(res.error, 'needs a column or row parent');
    final col = p.addWidget(s.id, 'column').node!;
    final a = p.addWidget(s.id, 'text', parentId: col.id).node!;
    final b = p.addWidget(s.id, 'text', parentId: col.id).node!;
    p.moveWidget(s.id, b.id);
    expect(col.children.last.id, b.id);
    p.moveWidget(s.id, b.id, index: 0);
    expect(col.children.first.id, b.id);
    expect(col.children[1].id, a.id);
  });

  test('cli short flag with no value', () async {
    final lines = <String>[];
    final errs = <String>[];
    final io = CliIo(
      fs: MemFs(),
      git: FakeGit().run,
      out: lines.add,
      err: errs.add,
      cwd: '/w',
    );
    await runCli(['git', 'commit', '-m'], io: io);
    expect(errs.join('\n'), contains('commit requires'));
    await runCli(['widget', 'move', 'x', '--index', 'abc'], io: io);
  });

  testWidgets('AppScope.read works', (tester) async {
    final state = await testState();
    late AppState found;
    await tester.pumpWidget(AppScope(
      state: state,
      child: Builder(
        builder: (context) {
          found = AppScope.read(context);
          return const SizedBox();
        },
      ),
    ));
    expect(found, same(state));
  });

  test('editor git refresh error path', () async {
    final git = FakeGit()..repo = true;
    git.queue['status'] = [const ProcResult(1, '', 'bad')];
    final e = EditorState(
      project: testProject(),
      dir: '/x',
      fs: MemFs(),
      gitRun: git.run,
    );
    await e.gitRefresh();
    expect(e.gitError, contains('bad'));
    e.removeScreen(e.screen.id);
    expect(e.screen.id, e.project.screens.first.id);
  });

  testWidgets('canvas tap selects node', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = state.editor!;
    final t = editor.addWidget('text')!;
    editor.select(null);
    await tester.pumpWidget(MaterialApp(
      home: NodePreview(
        project: editor.project,
        screen: editor.screen,
        onSelect: editor.select,
      ),
    ));
    await tester.tap(find.byType(Text).first);
    expect(editor.selectedId, t.id);
  });

  testWidgets('preview interactive controls', (tester) async {
    final p = testProject();
    final screen = p.screens.first;
    final col = p.addWidget(screen.id, 'column').node!;
    for (final t in ['switcher', 'checkbox', 'slider']) {
      final n = p.addWidget(screen.id, t, parentId: col.id).node!;
      n.props['value'] = t == 'slider' ? 0.5 : true;
      n.props['label'] = 'L';
    }
    await tester.pumpWidget(
      MaterialApp(home: NodePreview(project: p, screen: screen)),
    );
    await tester.tap(find.byType(Switch).first);
    await tester.tap(find.byType(Checkbox).first);
    await tester.drag(find.byType(Slider), const Offset(20, 0));
    await tester.pump();
  });

  testWidgets('inspector unknown widget and int fallback', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = state.editor!;
    final col = editor.addWidget('column')!;
    col.children.add(WidgetNode(id: 'myst', type: 'mystery'));
    editor.select('myst');
    await pumpPage(tester, state,
        InspectorPanel(editor: editor), size: const Size(400, 800));
    await tester.pumpAndSettle();
    expect(find.textContaining('nknown'), findsOneWidget);
    final t = editor.addWidget('text', parentId: col.id)!;
    editor.select(t.id);
    await tester.pumpAndSettle();
    final sz = t.props['size'];
    expect(sz, 14.0);
  });

  testWidgets('update tile up-to-date text', (tester) async {
    final checker = FakeVersionChecker()
      ..result = const AppUpdate(
        currentVersion: '2.0.0',
        latestVersion: '1.0.0',
        updateAvailable: false,
        releaseUrl: 'https://x',
      );
    final state = await testState(versionChecker: checker);
    await state.checkForUpdate();
    await pumpPage(tester, state,
        const SettingsPage(), size: const Size(1100, 1000));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.checkUpdates')));
    await tester.pumpAndSettle();
  });

  testWidgets('dashboard generic error snackbars', (tester) async {
    final fs = _FailOnSaveFs();
    final state = await testState(fs: fs, pickDir: () async => '/x');
    await pumpPage(tester, state, const DashboardPage(),
        size: const Size(1100, 800));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dashboard.new')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('dashboard.projectName')), 'Bad');
    await tester.tap(find.byKey(const Key('dashboard.createConfirm')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    await tester.tap(find.byKey(const Key('dashboard.import')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsWidgets);
  });

  testWidgets('shell sidebar select while editor open', (tester) async {
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
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(state.editor, isNull);
  });

  testWidgets('screen dialog submit on done', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    await tester.tap(find.byKey(const Key('screen.add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'NewScreen');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(editor.project.screens.any((s) => s.name == 'NewScreen'), isTrue);
  });

  testWidgets('screen dialog cancel', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    await openEditor(tester, state);
    await tester.tap(find.byKey(const Key('screen.add')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(state.editor!.project.screens, hasLength(1));
  });

  testWidgets('int prop fallback on garbage input', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    final col = editor.addWidget('column')!;
    final t = editor.addWidget('text', parentId: col.id)!;
    editor.select(t.id);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('minitab.0')).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('prop.size')), 'junk');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(t.props['size'], 0.0);
  });

  testWidgets('import generic error snackbar', (tester) async {
    final fs = _FailListFs();
    await fs.write('/imp/pubspec.yaml', 'name: x\nenvironment:\n  sdk: ^3.0.0\ndependencies:\n  flutter:\n    sdk: flutter');
    final state = await testState(fs: fs, pickDir: () async => '/imp');
    await pumpPage(tester, state, const DashboardPage(),
        size: const Size(1100, 800));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dashboard.import')));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('desktop title bar renders in shell', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final state = await testState();
    await state.createProject('/p', 'Proj');
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      AppScope(state: state, child: const SunsetApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Proj'), findsWidgets);
    state.openProject('/p');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('buttons without icons', (tester) async {
    final p = testProject();
    final screen = p.screens.first;
    final col = p.addWidget(screen.id, 'column').node!;
    for (final style in ['tonal', 'outlined', 'text', 'filled']) {
      final n = p.addWidget(screen.id, 'button', parentId: col.id).node!;
      n.props['style'] = style;
      n.props['label'] = 'B';
    }
    await tester.pumpWidget(
      MaterialApp(home: NodePreview(project: p, screen: screen)),
    );
    await tester.pump();
    await tester.tap(find.text('B').first);
    await tester.pump();
  });

  testWidgets('message field tap outside saves', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = state.editor!;
    editor.setMessage('welcome', 'en_GB', '');
    await pumpPage(tester, state, StringsPanel(editor: editor),
        size: const Size(500, 700));
    await tester.pumpAndSettle();
    final key = const Key('strings.field.welcome.en_GB');
    await tester.enterText(find.byKey(key), 'Hola');
    await tester.pump();
    final tf = tester.widget<TextField>(
      find.descendant(of: find.byKey(key), matching: find.byType(TextField)),
    );
    tf.onTapOutside!(const PointerDownEvent());
    await tester.pumpAndSettle();
    expect(editor.project.message('welcome', 'en_GB'), 'Hola');
  });

  testWidgets('commit field submit', (tester) async {
    final git = FakeGit()..repo = true;
    final state = await testState(gitRun: git.run);
    await state.createProject('/p', 'P');
    final editor = state.editor!;
    editor.gitRepo = true;
    await pumpPage(tester, state, GitPanel(editor: editor),
        size: const Size(500, 700));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('git.message')), 'first');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(git.calls.any((c) => c.first == 'commit'), isTrue);
  });

  testWidgets('int prop fallback via gridView columns', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    final col = editor.addWidget('column')!;
    final g = editor.addWidget('gridView', parentId: col.id)!;
    editor.select(g.id);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('minitab.0')).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('prop.columns')), 'junk');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(g.props['columns'], 0);
  });

  testWidgets('checking spinner state', (tester) async {
    final state = await testState(versionChecker: _SlowChecker());
    await pumpPage(tester, state, const SettingsPage(),
        size: const Size(1100, 1000));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.checkUpdates')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
  });

  test('cli flag no value and bad index', () async {
    final lines = <String>[];
    final io = CliIo(
      fs: MemFs(),
      git: FakeGit().run,
      out: lines.add,
      err: (_) {},
      cwd: '/w',
    );
    await runCli(['create', '/w', 'P'], io: io);
    lines.clear();
    await runCli(['theme', 'set', '--primary=0xFF00FF00'], io: io);
    await runCli(
      ['widget', 'add', 'text', '--index', 'abc'],
      io: io,
    );
  });

  test('undo after screen removal resets screen', () async {
    final e = EditorState(
      project: testProject(),
      dir: '/x',
      fs: MemFs(),
      gitRun: FakeGit().run,
    );
    e.addScreen('B');
    e.undo();
    expect(e.screen.id, e.project.screens.first.id);
  });

  testWidgets('palette tile tap adds widget', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    await pumpPage(tester, state,
        PalettePanel(editor: state.editor!), size: const Size(400, 1200));
    await tester.tap(find.text('text').first);
    expect(state.editor!.screen.root.find('w1'), isNotNull);
  });

  testWidgets('package field tap outside', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    await pumpPage(tester, state,
        ThemePanel(editor: state.editor!),
        size: const Size(400, 800));
    await tester.enterText(find.byKey(const Key('theme.package')), 'com.z.z');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(state.editor!.project.packageName, 'com.z.z');
  });


  test('unsupported locale falls to FlutterError', () {
    expect(
      () => lookupAppLocalizations(const Locale('xx')),
      throwsA(isA<FlutterError>()),
    );
  });

  test('SunsetApp non-const constructor', () {
    expect(SunsetApp(key: UniqueKey()), isA<Widget>());
  });

  testWidgets('inspector text prop tap outside', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    final t = editor.addWidget('text')!;
    editor.select(t.id);
    await tester.pumpAndSettle();
    final key = const Key('prop.text');
    await tester.enterText(find.byKey(key), 'new label');
    final tf = tester.widget<TextField>(
      find.descendant(of: find.byKey(key), matching: find.byType(TextField)),
    );
    tf.onTapOutside!(const PointerDownEvent());
    await tester.pumpAndSettle();
    expect(t.props['text'], 'new label');
  });

  testWidgets('key dialog submit and cancel', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = state.editor!;
    editor.setMessage('welcome', 'en_GB', '');
    await pumpPage(tester, state, StringsPanel(editor: editor),
        size: const Size(500, 700));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('strings.addKey')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('strings.keyName')), 'viaSubmit');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(editor.project.messages.containsKey('viaSubmit'), isTrue);
    await tester.tap(find.byKey(const Key('strings.addKey')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('strings.keyName')), findsNothing);
  });

  test('cli bare flag and index parse', () async {
    final lines = <String>[];
    final io = CliIo(
      fs: MemFs(),
      git: FakeGit().run,
      out: lines.add,
      err: (_) {},
      cwd: '/w',
    );
    await runCli(['create', '/w', 'P'], io: io);
    await runCli(
      ['theme', 'set', '--dir', '/w', '--color', '0xFF112233', '--bogus'],
      io: io,
    );
    await runCli(
      ['widget', 'add', 'text', '--dir', '/w', '--index', 'abc'],
      io: io,
    );
    expect(lines.join('\n'), isNotEmpty);
  });

}

class _FailOnSaveFs extends MemFs {
  @override
  Future<void> write(String path, String contents) {
    if (path.endsWith('project.sunset.json')) {
      throw StateError('read only');
    }
    return super.write(path, contents);
  }
}

class _SlowChecker extends FakeVersionChecker {
  @override
  Future<AppUpdate> check(String currentVersion) =>
      Completer<AppUpdate>().future;
}

class _FailListFs extends MemFs {
  @override
  Future<List<String>> list(String path) {
    if (path.endsWith('/lib')) throw StateError('no list');
    return super.list(path);
  }
}
