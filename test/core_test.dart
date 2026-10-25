import 'package:flutter_test/flutter_test.dart';
import 'package:sunset/core/catalog.dart';
import 'package:sunset/core/codegen.dart';
import 'package:sunset/core/fs.dart';
import 'package:sunset/core/fs_io.dart';
import 'package:sunset/core/git_service.dart';
import 'package:sunset/core/importer.dart';
import 'package:sunset/core/model.dart';
import 'package:sunset/core/store.dart';

import 'dart:io';

void main() {
  group('WidgetNode', () {
    test('json round trip', () {
      final node = WidgetNode(id: 'w1', type: 'column', props: {'spacing': 8.0})
        ..children.add(WidgetNode(id: 'w2', type: 'text'));
      final copy = WidgetNode.fromJson(node.toJson());
      expect(copy.id, 'w1');
      expect(copy.type, 'column');
      expect(copy.props['spacing'], 8.0);
      expect(copy.children.single.id, 'w2');
    });

    test('find, parentOf, walk, detach, clone', () {
      final root = WidgetNode(id: 'root', type: 'column');
      final mid = WidgetNode(id: 'mid', type: 'row');
      final leaf = WidgetNode(id: 'leaf', type: 'text');
      root.children.add(mid);
      mid.children.add(leaf);
      expect(root.find('leaf')!.type, 'text');
      expect(root.find('nope'), isNull);
      expect(root.parentOf('leaf')!.id, 'mid');
      expect(root.walk().map((n) => n.id).toList(), ['root', 'mid', 'leaf']);
      final clone = root.clone();
      expect(clone.children.single.children.single.id, 'leaf');
      expect(root.detach('leaf'), isTrue);
      expect(root.find('leaf'), isNull);
      expect(root.detach('leaf'), isFalse);
    });
  });

  group('SunsetProject', () {
    test('create makes a Home screen with scaffold', () {
      final p = SunsetProject.create('My App');
      expect(p.screens, hasLength(1));
      expect(p.screens.first.root.type, 'scaffold');
      expect(p.packageName, 'com.example.myapp');
      expect(p.locales, ['en_GB']);
    });

    test('json round trip keeps everything', () {
      final p = SunsetProject.create('App')
        ..description = 'desc'
        ..imported = true
        ..importedFiles = ['lib/a.dart'];
      p.addLocale('ru');
      p.setMessage('k', 'ru', 'text');
      p.theme.seedColor = 0xFF123456;
      p.theme.brightness = ThemeBrightness.dark;
      p.theme.radius = 20;
      final back = SunsetProject.decode(p.encode());
      expect(back.name, 'App');
      expect(back.description, 'desc');
      expect(back.imported, isTrue);
      expect(back.importedFiles, ['lib/a.dart']);
      expect(back.locales, contains('ru'));
      expect(back.messages['k']!['ru'], 'text');
      expect(back.theme.seedColor, 0xFF123456);
      expect(back.theme.brightness, ThemeBrightness.dark);
      expect(back.theme.radius, 20);
      expect(back.idCounter, p.idCounter);
    });

    test('screen ops', () {
      final p = SunsetProject.create('App');
      final s = p.addScreen('Second');
      expect(p.screenById(s.id), s);
      expect(p.screenById('nope'), isNull);
      expect(p.renameScreen(s.id, 'Two'), isTrue);
      expect(p.renameScreen('nope', 'x'), isFalse);
      expect(s.name, 'Two');
      expect(p.removeScreen('nope'), isFalse);
      expect(p.removeScreen(s.id), isTrue);
      expect(p.removeScreen(p.screens.first.id), isFalse);
    });

    test('widget ops', () {
      final p = SunsetProject.create('App');
      final screen = p.screens.first;
      expect(p.addWidget('nope', 'text').error, 'screen not found');
      expect(
        p.addWidget(screen.id, 'text', parentId: 'nope').error,
        'parent not found',
      );
      final added = p.addWidget(screen.id, 'column');
      expect(added.node, isNotNull);
      final colId = added.node!.id;
      final full = p.addWidget(screen.id, 'text');
      expect(full.node, isNull);
      expect(full.error, 'parent is full');

      final t1 = p.addWidget(screen.id, 'text', parentId: colId).node!;
      final t2 = p
          .addWidget(screen.id, 'text', parentId: colId, index: 0)
          .node!;
      expect(screen.root.find(colId)!.children.map((c) => c.id).toList(), [
        t2.id,
        t1.id,
      ]);

      expect(p.setProp(screen.id, t1.id, 'text', 'hi'), isTrue);
      expect(t1.props['text'], 'hi');
      expect(p.setProp('nope', t1.id, 'x', 'y'), isFalse);
      expect(p.setProp(screen.id, 'nope', 'x', 'y'), isFalse);

      expect(p.moveWidget(screen.id, t1.id, index: 0), isTrue);
      expect(screen.root.find(colId)!.children.map((c) => c.id).toList(), [
        t1.id,
        t2.id,
      ]);
      expect(p.moveWidget(screen.id, 'nope', index: 0), isFalse);
      expect(p.moveWidget(screen.id, screen.root.id), isFalse);
      expect(p.moveWidget(screen.id, colId, parentId: t1.id), isFalse);
      expect(p.removeWidget(screen.id, screen.root.id), isFalse);
      expect(p.removeWidget('nope', t1.id), isFalse);
      expect(p.removeWidget(screen.id, t1.id), isTrue);
    });

    test('locale and message ops', () {
      final p = SunsetProject.create('App');
      p.addLocale('ru');
      p.addLocale('ru');
      expect(p.locales.where((l) => l == 'ru'), hasLength(1));
      p.setMessage('k', 'en_GB', 'hi');
      p.setMessage('k', 'ru', 'privet');
      expect(p.message('k', 'ru'), 'privet');
      expect(p.message('k', 'xx'), 'hi');
      expect(p.message('nope', 'en_GB'), isNull);
      expect(p.removeLocale('ru'), isTrue);
      expect(p.messages['k']!.containsKey('ru'), isFalse);
      expect(p.removeLocale('en_GB'), isFalse);
      expect(p.removeMessage('k'), isTrue);
      expect(p.removeMessage('k'), isFalse);
    });

    test('empty locale message fallback', () {
      final p = SunsetProject(name: 'x', packageName: 'y', locales: []);
      p.setMessage('k', 'en_GB', 'v');
      expect(p.message('k', 'zz'), 'v');
    });
  });

  group('catalog', () {
    test('every def is findable and valid', () {
      for (final def in catalog) {
        expect(widgetDef(def.type), same(def));
        for (final p in def.props) {
          if (p.kind == PropKind.enumProp ||
              p.kind == PropKind.icon ||
              p.kind == PropKind.align) {
            expect(p.options, isNotEmpty, reason: '${def.type}.${p.name}');
          }
        }
      }
      expect(widgetDef('nope'), isNull);
      expect(propDefault('text', 'size'), 14.0);
      expect(propDefault('text', 'nope'), isNull);
      expect(propDefault('nope', 'x'), isNull);
    });

    test('parsePropValue', () {
      expect(parsePropValue(const PropDef('x', PropKind.int, 0), '42'), 42);
      expect(parsePropValue(const PropDef('x', PropKind.int, 0), 'no'), isNull);
      expect(
        parsePropValue(const PropDef('x', PropKind.double, 0), '1.5'),
        1.5,
      );
      expect(
        parsePropValue(const PropDef('x', PropKind.bool, false), 'yes'),
        isTrue,
      );
      expect(
        parsePropValue(const PropDef('x', PropKind.bool, false), 'off'),
        isFalse,
      );
      expect(
        parsePropValue(const PropDef('x', PropKind.bool, false), 'meh'),
        isNull,
      );
      expect(
        parsePropValue(const PropDef('x', PropKind.color, 0), 'FF3813'),
        0xFFFF3813,
      );
      expect(
        parsePropValue(const PropDef('x', PropKind.color, 0), '#80FF3813'),
        0x80FF3813,
      );
      expect(
        parsePropValue(const PropDef('x', PropKind.color, 0), 'nope'),
        isNull,
      );
      expect(
        parsePropValue(
          const PropDef('x', PropKind.enumProp, 'a', ['a', 'b']),
          'b',
        ),
        'b',
      );
      expect(
        parsePropValue(
          const PropDef('x', PropKind.enumProp, 'a', ['a', 'b']),
          'c',
        ),
        isNull,
      );
      expect(
        parsePropValue(const PropDef('x', PropKind.string, ''), 'raw'),
        'raw',
      );
    });
  });

  group('codegen', () {
    SunsetProject buildProject() {
      final p = SunsetProject.create('Demo App')
        ..description = 'A "quoted" desc';
      final screen = p.screens.first;
      final col = p.addWidget(screen.id, 'column').node!;
      for (final prop in widgetDef('column')!.props) {
        col.props[prop.name] = prop.value;
      }
      col.props['spacing'] = 8.0;
      for (final def in catalog) {
        if (def.type == 'scaffold') continue;
        final res = p.addWidget(screen.id, def.type, parentId: col.id);
        if (res.node != null) {
          for (final prop in def.props) {
            res.node!.props[prop.name] = prop.value;
          }
        }
      }
      // nested children so container branches get exercised
      final inner = p.addWidget(screen.id, 'column', parentId: col.id).node!;
      inner.props['spacing'] = 4.0;
      for (final type in ['text', 'button', 'icon', 'divider', 'spacer']) {
        final n = p.addWidget(screen.id, type, parentId: inner.id).node!;
        for (final prop in widgetDef(type)!.props) {
          n.props[prop.name] = prop.value;
        }
      }
      final row = p.addWidget(screen.id, 'row', parentId: col.id).node!;
      row.props['spacing'] = 4.0;
      for (final type in ['text', 'icon']) {
        final n = p.addWidget(screen.id, type, parentId: row.id).node!;
        for (final prop in widgetDef(type)!.props) {
          n.props[prop.name] = prop.value;
        }
      }
      final lv = p.addWidget(screen.id, 'listView', parentId: col.id).node!;
      lv.props['spacing'] = 4.0;
      lv.props['padding'] = 8.0;
      final lv2 = p.addWidget(screen.id, 'listView', parentId: col.id).node!;
      lv2.props['height'] = 150.0;
      for (final type in ['text', 'card']) {
        final n = p.addWidget(screen.id, type, parentId: lv.id).node!;
        for (final prop in widgetDef(type)!.props) {
          n.props[prop.name] = prop.value;
        }
      }
      final grid = p.addWidget(screen.id, 'gridView', parentId: col.id).node!;
      final grid2 = p.addWidget(screen.id, 'gridView', parentId: col.id).node!;
      grid2.props['height'] = 150.0;
      for (final type in ['text', 'icon']) {
        final n = p.addWidget(screen.id, type, parentId: grid.id).node!;
        for (final prop in widgetDef(type)!.props) {
          n.props[prop.name] = prop.value;
        }
      }
      for (final holder in [
        'stack',
        'center',
        'padding',
        'expanded',
        'sizedBox',
        'container',
        'card',
      ]) {
        final target = col.children.firstWhere((n) => n.type == holder);
        final n = p.addWidget(screen.id, 'text', parentId: target.id).node!;
        for (final prop in widgetDef('text')!.props) {
          n.props[prop.name] = prop.value;
        }
      }
      p.setMessage('hello', 'en_GB', 'Hi \'there\' \$100');
      final text = inner.children.firstWhere((n) => n.type == 'text');
      text.props['textKey'] = 'hello';
      return p;
    }

    test('generates a full project', () {
      final files = generateProject(buildProject());
      expect(
        files.keys,
        containsAll([
          'pubspec.yaml',
          'lib/main.dart',
          'lib/sunset_l10n.dart',
          'lib/screens/home.dart',
          'analysis_options.yaml',
          '.gitignore',
        ]),
      );
      expect(files['pubspec.yaml'], contains('name: demo_app'));
      expect(files['lib/main.dart'], contains('DemoApp'));
      expect(files['lib/main.dart'], contains('ThemeMode.system'));
      expect(files['lib/sunset_l10n.dart'], contains('SunsetL10n'));
      expect(files['lib/sunset_l10n.dart'], contains('Hi'));
      expect(files['lib/screens/home.dart'], contains('Scaffold'));
      expect(files['lib/screens/home.dart'], contains('LayoutBuilder'));
      expect(
        files['lib/screens/home.dart'],
        contains('SunsetL10n.of(context)'),
      );
    });

    test('imported project skips host files', () {
      final p = buildProject()..imported = true;
      final files = generateProject(p);
      expect(files.keys, isNot(contains('pubspec.yaml')));
      expect(files.keys, isNot(contains('lib/main.dart')));
      expect(files.keys, contains('lib/screens/home.dart'));
    });

    test('theme modes and non-responsive screen', () {
      final p = buildProject();
      p.theme.brightness = ThemeBrightness.dark;
      p.screens.first.responsive = false;
      var files = generateProject(p);
      expect(files['lib/main.dart'], contains('ThemeMode.dark'));
      expect(files['lib/screens/home.dart'], isNot(contains('LayoutBuilder')));
      p.theme.brightness = ThemeBrightness.light;
      files = generateProject(p);
      expect(files['lib/main.dart'], contains('ThemeMode.light'));
    });

    test('locales and screens emitted', () {
      final p = buildProject();
      p.addLocale('zh_Hans');
      p.setMessage('hello', 'zh_Hans', '你好');
      p.addScreen('Second Page');
      p.screens.last.root.props['showAppBar'] = false;
      final files = generateProject(p);
      expect(files.keys, contains('lib/screens/second_page.dart'));
      expect(
        files['lib/screens/second_page.dart'],
        contains('SecondPageScreen'),
      );
      expect(files['lib/screens/second_page.dart'], isNot(contains('appBar')));
      expect(files['lib/sunset_l10n.dart'], contains('zh'));
      expect(files['lib/sunset_l10n.dart'], contains('你好'));
    });

    test('snake and pascal names', () {
      expect(snakeName('My Cool App'), 'my_cool_app');
      expect(snakeName(''), 'app');
      expect(snakeName('SecondPage'), 'second_page');
      expect(pascalName('my_cool_app'), 'MyCoolApp');
    });

    test('button styles and icons', () {
      final p = SunsetProject.create('B');
      final s = p.screens.first;
      final col = p.addWidget(s.id, 'column').node!;
      for (final style in ['tonal', 'outlined', 'text', 'filled']) {
        final n = p.addWidget(s.id, 'button', parentId: col.id).node!;
        n.props['style'] = style;
        n.props['icon'] = 'star';
        n.props['label'] = 'Go';
      }
      final plain = p.addWidget(s.id, 'button', parentId: col.id).node!;
      plain.props['style'] = 'filled';
      plain.props['icon'] = '';
      final code = generateProject(p)['lib/screens/home.dart']!;
      expect(code, contains('FilledButton.tonal.icon'));
      expect(code, contains('OutlinedButton.icon'));
      expect(code, contains('TextButton.icon'));
      expect(code, contains('FilledButton.icon'));
      expect(code, contains('FilledButton('));
    });

    test('image empty vs url', () {
      final p = SunsetProject.create('I');
      final s = p.screens.first;
      final col = p.addWidget(s.id, 'column').node!;
      final empty = p.addWidget(s.id, 'image', parentId: col.id).node!;
      empty.props['url'] = '';
      final withUrl = p.addWidget(s.id, 'image', parentId: col.id).node!;
      withUrl.props['url'] = 'https://x/y.png';
      final code = generateProject(p)['lib/screens/home.dart']!;
      expect(code, contains('Image.network'));
      expect(code, contains('Icons.image_outlined'));
    });
  });

  group('MemFs', () {
    test('read/write/exists/list/delete', () async {
      final fs = MemFs();
      await fs.write('/a/b/c.txt', 'hi');
      await fs.write('/a/d.txt', 'yo');
      expect(await fs.read('/a/b/c.txt'), 'hi');
      expect(await fs.read('/a/nope.txt'), isNull);
      expect(await fs.exists('/a/b'), isTrue);
      expect(await fs.isDir('/a/b'), isTrue);
      expect(await fs.isDir('/a/d.txt'), isFalse);
      expect(await fs.list('/a'), ['b/', 'b/c.txt', 'd.txt']);
      await fs.delete('/a/b');
      expect(await fs.exists('/a/b/c.txt'), isFalse);
      expect(await fs.exists('/a/d.txt'), isTrue);
    });
  });

  group('IoFs', () {
    test('real filesystem round trip', () async {
      final dir = await Directory.systemTemp.createTemp('sunset_test');
      addTearDown(() => dir.delete(recursive: true));
      final fs = IoFs();
      final root = dir.path;
      await fs.write('$root/sub/file.txt', 'contents');
      expect(await fs.read('$root/sub/file.txt'), 'contents');
      expect(await fs.read('$root/nope'), isNull);
      expect(await fs.exists('$root/sub'), isTrue);
      expect(await fs.isDir('$root/sub'), isTrue);
      expect(await fs.isDir('$root/sub/file.txt'), isFalse);
      final listing = await fs.list(root);
      expect(listing, ['sub/', 'sub/file.txt']);
      expect(await fs.list('$root/missing'), isEmpty);
      await fs.delete('$root/sub');
      expect(await fs.exists('$root/sub/file.txt'), isFalse);
      await fs.write('$root/deep/a/b.txt', 'x');
      await fs.delete('$root/deep/a/b.txt');
      expect(await fs.exists('$root/deep/a/b.txt'), isFalse);
    });
  });

  group('ProjectStore', () {
    test('create, load, save, existsAt, tryLoad', () async {
      final fs = MemFs();
      final store = ProjectStore(fs);
      expect(await store.existsAt('/p'), isFalse);
      expect(await store.tryLoad('/p'), isNull);
      expect(() => store.load('/p'), throwsStateError);
      await store.create('/p', name: 'Test');
      expect(await store.existsAt('/p'), isTrue);
      final loaded = await store.load('/p');
      expect(loaded.name, 'Test');
      loaded.setMessage('x', 'en_GB', 'y');
      await store.save('/p', loaded);
      expect((await store.load('/p')).messages['x']!['en_GB'], 'y');
    });
  });

  group('importer', () {
    test('imports a real flutter project layout', () async {
      final fs = MemFs();
      await fs.write(
        '/app/pubspec.yaml',
        'name: cool_app\ndependencies:\n  flutter:\n    sdk: flutter\n',
      );
      await fs.write('/app/lib/main.dart', 'void main() {}');
      await fs.write('/app/lib/src/thing.dart', 'class Thing {}');
      await fs.write('/app/lib/readme.txt', 'not dart');
      final result = await importFlutterProject(fs, '/app');
      expect(result.project.name, 'cool_app');
      expect(result.project.imported, isTrue);
      expect(
        result.dartFiles,
        containsAll(['lib/main.dart', 'lib/src/thing.dart']),
      );
      expect(await fs.exists('/app/project.sunset.json'), isTrue);
      final again = await importFlutterProject(fs, '/app');
      expect(again.project.screens, hasLength(1));
    });

    test('rejects non-flutter and missing pubspec', () async {
      final fs = MemFs();
      expect(
        () => importFlutterProject(fs, '/none'),
        throwsA(isA<ImportException>()),
      );
      await fs.write('/x/pubspec.yaml', 'name: plain\n');
      expect(
        () => importFlutterProject(fs, '/x'),
        throwsA(isA<ImportException>()),
      );
    });
  });

  group('GitService', () {
    ProcRun fake(Map<String, ProcResult> answers) =>
        (args, cwd) async => answers[args.first] ?? const ProcResult(0, '', '');

    test('isRepo/init/status/log/branch/commit', () async {
      final git = GitService(
        fake({
          'rev-parse': const ProcResult(0, 'true\n', ''),
          'init': const ProcResult(0, '', ''),
          'status': const ProcResult(0, ' M a.dart\n?? b.txt\n', ''),
          'log': const ProcResult(
            0,
            'abc1234\x1finitial\x1f2026-01-01\nbad\n',
            '',
          ),
          'branch': const ProcResult(0, 'main\n', ''),
        }),
      );
      expect(await git.isRepo('/r'), isTrue);
      await git.init('/r');
      final files = await git.status('/r');
      expect(files, hasLength(2));
      expect(files[0].status, 'M');
      expect(files[0].path, 'a.dart');
      expect(files[1].status, '??');
      final commits = await git.log('/r');
      expect(commits.single.hash, 'abc1234');
      expect(commits.single.subject, 'initial');
      expect(await git.currentBranch('/r'), 'main');
      await git.commit('/r', 'msg');
    });

    test('not a repo and failures', () async {
      final git = GitService(
        fake({
          'rev-parse': const ProcResult(128, '', 'fatal'),
          'status': const ProcResult(1, '', ''),
          'init': const ProcResult(128, '', 'boom'),
        }),
      );
      expect(await git.isRepo('/x'), isFalse);
      expect(() => git.init('/x'), throwsA(isA<GitException>()));
      expect(() => git.status('/x'), throwsA(isA<GitException>()));
    });
  });
}
