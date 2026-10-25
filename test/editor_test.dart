import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunset/core/fs.dart';
import 'package:sunset/core/model.dart';
import 'package:sunset/state/app_state.dart';
import 'package:sunset/state/editor_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sunset/l10n/app_localizations.dart';
import 'package:sunset/ui/editor/preview.dart';
import 'package:sunset/ui/pages/project_page.dart';

import 'fakes.dart';

Future<EditorState> openEditor(
  WidgetTester tester,
  AppState state, {
  Size size = const Size(1500, 950),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(fontFamily: 'Inter'),
        home: Scaffold(body: ProjectPage(editor: state.editor!)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return state.editor!;
}

void main() {
  testWidgets('editor adds every catalog widget via palette', (tester) async {
    final fs = MemFs();
    final state = await testState(fs: fs);
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    for (final type in [
      'column',
      'row',
      'stack',
      'center',
      'padding',
      'expanded',
      'sizedBox',
      'container',
      'card',
      'listView',
      'gridView',
      'divider',
      'spacer',
      'text',
      'icon',
      'image',
      'circleAvatar',
      'button',
      'textField',
      'switcher',
      'checkbox',
      'slider',
      'progress',
    ]) {
      editor.addWidget(type);
      await tester.pump();
    }
    final types = editor.screen.root.walk().map((n) => n.type).toSet();
    for (final type in [
      'column',
      'row',
      'stack',
      'center',
      'padding',
      'expanded',
      'sizedBox',
      'container',
      'card',
      'listView',
      'gridView',
      'divider',
      'spacer',
      'text',
      'icon',
      'image',
      'circleAvatar',
      'button',
      'textField',
      'switcher',
      'checkbox',
      'slider',
      'progress',
    ]) {
      expect(types, contains(type), reason: type);
    }
    expect(find.byType(Column), findsWidgets);
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('canvas selection, tree, inspector edits', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    final col = editor.addWidget('column')!;
    final text = editor.addWidget('text', parentId: col.id)!;
    editor.select(null);
    await tester.pump();

    // select via the tree
    await tester.tap(find.byKey(const Key('minitab.1')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('tree.${text.id}')));
    await tester.pumpAndSettle();
    expect(editor.selectedId, text.id);

    // inspector: string prop
    await tester.enterText(find.byKey(const Key('prop.text')), 'Hello canvas');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(text.props['text'], 'Hello canvas');

    // numeric prop
    await tester.enterText(find.byKey(const Key('prop.size')), '20');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(text.props['size'], 20.0);

    // bool prop
    await tester.tap(find.byKey(const Key('prop.bold')));
    await tester.pumpAndSettle();
    expect(text.props['bold'], isTrue);

    // enum prop
    await tester.tap(find.byKey(const Key('prop.align')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('center').last);
    await tester.pumpAndSettle();
    expect(text.props['align'], 'center');

    // color prop
    await tester.tap(find.byKey(const Key('prop.color.ffe84c6f')));
    await tester.pumpAndSettle();
    expect(text.props['color'], 0xFFE84C6F);

    // l10n key prop
    editor.project.setMessage('greeting', 'en_GB', 'Hey');
    editor.select(text.id);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('prop.textKey')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('greeting').last);
    await tester.pumpAndSettle();
    expect(text.props['textKey'], 'greeting');
    expect(find.text('Hey'), findsWidgets);

    // reorder + delete buttons
    await tester.tap(find.byKey(const Key('inspector.down')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inspector.up')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inspector.delete')));
    await tester.pumpAndSettle();
    expect(editor.screen.root.find(text.id), isNull);
  });

  testWidgets('inspector empty state and icon/color/align editors', (
    tester,
  ) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    expect(find.textContaining('Select a widget'), findsOneWidget);
    final col = editor.addWidget('column')!;
    final icon = editor.addWidget('icon', parentId: col.id)!;
    editor.select(icon.id);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('prop.icon')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('search').last);
    await tester.pumpAndSettle();
    expect(icon.props['icon'], 'search');

    final cont = editor.addWidget('container', parentId: col.id)!;
    editor.select(cont.id);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('prop.align')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('bottomRight').last);
    await tester.pumpAndSettle();
    expect(cont.props['align'], 'bottomRight');
  });

  testWidgets('screens add rename switch remove', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    await tester.tap(find.byKey(const Key('screen.add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('screen.name')), 'Second');
    await tester.tap(find.byKey(const Key('screen.confirm')));
    await tester.pumpAndSettle();
    expect(editor.screen.name, 'Second');

    await tester.tap(find.byKey(const Key('screen.rename')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('screen.name')), 'Two');
    await tester.tap(find.byKey(const Key('screen.confirm')));
    await tester.pumpAndSettle();
    expect(editor.screen.name, 'Two');

    final home = editor.project.screens.first;
    await tester.tap(find.byKey(Key('screen.${home.id}')));
    await tester.pumpAndSettle();
    expect(editor.screen.id, home.id);

    await tester.tap(
      find.byKey(Key('screen.${editor.project.screens.last.id}')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(Key('screen.${editor.screen.id}')),
        matching: find.byIcon(Icons.close),
      ),
    );
    await tester.pumpAndSettle();
    expect(editor.project.screens, hasLength(1));
  });

  testWidgets('device presets, preview brightness, undo, save', (tester) async {
    final fs = MemFs();
    final state = await testState(fs: fs);
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    await tester.tap(find.byIcon(Icons.tablet_mac));
    await tester.pumpAndSettle();
    expect(editor.device, DevicePreset.tablet);
    await tester.tap(find.byIcon(Icons.desktop_mac_outlined));
    await tester.pumpAndSettle();
    expect(editor.device, DevicePreset.desktop);
    await tester.tap(find.byIcon(Icons.phone_iphone));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('editor.brightness')));
    await tester.pumpAndSettle();
    expect(editor.previewDark, isTrue);

    editor.addWidget('text');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editor.undo')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('editor.save')));
    await tester.pumpAndSettle();
    expect(editor.dirty, isFalse);
    expect(await fs.exists('/p/project.sunset.json'), isTrue);
  });

  testWidgets('theme panel edits', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    await tester.tap(find.byKey(const Key('minitab.1')).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theme.seed.ff8a4fff')));
    await tester.pumpAndSettle();
    expect(editor.project.theme.seedColor, 0xFF8A4FFF);
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();
    expect(editor.project.theme.brightness, ThemeBrightness.dark);
    await tester.tap(find.byKey(const Key('theme.responsive')));
    await tester.pumpAndSettle();
    expect(editor.screen.responsive, isFalse);
    await tester.enterText(
      find.byKey(const Key('theme.package')),
      'com.acme.app',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(editor.project.packageName, 'com.acme.app');
  });

  testWidgets('strings panel manages locales and keys', (tester) async {
    final state = await testState();
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    await tester.tap(find.byKey(const Key('minitab.2')).last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('strings.addLocale')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('locale.pick.ru')));
    await tester.pumpAndSettle();
    expect(editor.project.locales, contains('ru'));

    await tester.tap(find.byKey(const Key('strings.addKey')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('strings.keyName')), 'title');
    await tester.tap(find.byKey(const Key('strings.keyConfirm')));
    await tester.pumpAndSettle();
    expect(editor.project.messages.keys, contains('title'));

    await tester.enterText(
      find.byKey(const Key('strings.field.title.en_GB')),
      'Hello',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(editor.project.messages['title']!['en_GB'], 'Hello');

    await tester.tap(find.byKey(const Key('strings.delete.title')));
    await tester.pumpAndSettle();
    expect(editor.project.messages.keys, isNot(contains('title')));

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('strings.locale.ru')),
        matching: find.byIcon(Icons.close),
      ),
    );
    await tester.pumpAndSettle();
    expect(editor.project.locales, isNot(contains('ru')));
  });

  testWidgets('git panel init status commit', (tester) async {
    final git = FakeGit();
    final state = await testState(gitRun: git.run);
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    await tester.tap(find.byKey(const Key('minitab.3')).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('git.init')));
    await tester.pumpAndSettle();
    expect(editor.gitRepo, isTrue);

    git.files = [' M lib/main.dart', '?? new.txt'];
    git.commits = ['abc1234\x1finitial commit\x1f2026'];
    await tester.tap(find.byKey(const Key('git.refresh')));
    await tester.pumpAndSettle();
    expect(find.text('lib/main.dart'), findsOneWidget);
    expect(find.text('initial commit'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('git.message')), 'test commit');
    await tester.tap(find.byKey(const Key('git.commit')));
    await tester.pumpAndSettle();
    expect(git.calls.any((c) => c.first == 'commit'), isTrue);
  });

  testWidgets('export panel writes files', (tester) async {
    final fs = MemFs();
    final state = await testState(fs: fs);
    await state.createProject('/p', 'P');
    await openEditor(tester, state);
    await tester.tap(find.byKey(const Key('minitab.4')).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('export.run')));
    await tester.pumpAndSettle();
    expect(await fs.exists('/p/lib/main.dart'), isTrue);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('preview renders bound strings and fallbacks', (tester) async {
    final project = testProject();
    final screen = project.screens.first;
    final orphan = project.addWidget(screen.id, 'column').node!;
    final text = project
        .addWidget(screen.id, 'text', parentId: orphan.id)
        .node!;
    text.props['textKey'] = 'hello';
    text.props['text'] = 'fallback';
    orphan.children.add(WidgetNode(id: 'wx', type: 'mystery'));
    final img = project
        .addWidget(screen.id, 'image', parentId: orphan.id)
        .node!;
    img.props['url'] = 'https://example.com/x.png';
    expect(img.type, 'image');
    await tester.pumpWidget(
      MaterialApp(
        home: NodePreview(project: project, screen: screen),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hello there'), findsOneWidget);
    expect(find.text('? mystery'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
