import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunset/core/fs.dart';
import 'package:sunset/core/git_service.dart';
import 'package:sunset/core/model.dart';
import 'package:sunset/core/store.dart';
import 'package:sunset/models/app_update.dart';
import 'package:sunset/state/editor_state.dart';
import 'package:sunset/state/project_registry.dart';
import 'package:sunset/state/settings_store.dart';

import 'fakes.dart';

void main() {
  group('SettingsStore', () {
    test('defaults, persistence, reload', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final s = await SettingsStore.load(prefs);
      expect(s.theme, AppTheme.system);
      expect(s.accentColor, 0xFFF3813F);
      expect(s.locale, isNull);
      await s.setTheme(AppTheme.oled, prefs);
      await s.setAccentColor(0xFF123456, prefs);
      await s.setLocale(const Locale('ru'), prefs);
      final reloaded = await SettingsStore.load(prefs);
      expect(reloaded.theme, AppTheme.oled);
      expect(reloaded.accentColor, 0xFF123456);
      expect(reloaded.locale, const Locale('ru'));
      await reloaded.setLocale(null, prefs);
      expect((await SettingsStore.load(prefs)).locale, isNull);
    });

    test('parseLocale ignores unknown tags', () async {
      SharedPreferences.setMockInitialValues({'locale': 'xx_YY'});
      final prefs = await SharedPreferences.getInstance();
      expect((await SettingsStore.load(prefs)).locale, isNull);
      SharedPreferences.setMockInitialValues({'locale': 'zh_Hans'});
      final prefs2 = await SharedPreferences.getInstance();
      expect(
        (await SettingsStore.load(prefs2)).locale,
        const Locale('zh', 'Hans'),
      );
    });
  });

  group('ProjectRegistry', () {
    test('add/remove/dedupe/persist/corrupt', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final reg = await ProjectRegistry.load(prefs);
      expect(reg.entries, isEmpty);
      await reg.add(
        const ProjectEntry(name: 'A', path: '/a'),
        prefs,
      );
      await reg.add(
        const ProjectEntry(name: 'A2', path: '/a', imported: true),
        prefs,
      );
      await reg.add(const ProjectEntry(name: 'B', path: '/b'), prefs);
      expect(reg.entries, hasLength(2));
      expect(reg.byPath('/a')!.name, 'A2');
      expect(reg.byPath('/none'), isNull);

      final reloaded = await ProjectRegistry.load(prefs);
      expect(reloaded.entries, hasLength(2));
      await reloaded.remove('/a', prefs);
      expect(reloaded.entries.single.path, '/b');

      SharedPreferences.setMockInitialValues({'projects': 'not json'});
      final bad = await SharedPreferences.getInstance();
      expect((await ProjectRegistry.load(bad)).entries, isEmpty);
      SharedPreferences.setMockInitialValues({'projects': '{"a":1}'});
      final bad2 = await SharedPreferences.getInstance();
      expect((await ProjectRegistry.load(bad2)).entries, isEmpty);
      SharedPreferences.setMockInitialValues({'projects': '[1,"x",{"name":"n","path":"/p"}]'});
      final bad3 = await SharedPreferences.getInstance();
      expect((await ProjectRegistry.load(bad3)).entries.single.name, 'n');
    });
  });

  group('AppState', () {
    test('tab selection and project open/close', () async {
      final fs = MemFs();
      final state = await testState(fs: fs);
      expect(state.tabIndex, 0);
      state.selectTab(1);
      expect(state.tabIndex, 1);
      state.selectTab(1);

      await state.createProject('/proj', 'Alpha');
      expect(state.editor, isNotNull);
      expect(state.editor!.project.name, 'Alpha');
      expect(state.registry.entries.single.path, '/proj');
      state.closeProject();
      expect(state.editor, isNull);
    });

    test('openProject loads from disk', () async {
      final fs = MemFs();
      await ProjectStore(fs).create('/saved', name: 'Saved');
      final state = await testState(fs: fs);
      await state.openProject('/saved');
      expect(state.editor!.project.name, 'Saved');
      await state.openProject('/saved');
      expect(state.registry.entries, hasLength(1));
    });

    test('importProject scans flutter files', () async {
      final fs = MemFs();
      await fs.write('/fp/pubspec.yaml',
          'name: fp\ndependencies:\n  flutter:\n    sdk: flutter\n');
      await fs.write('/fp/lib/main.dart', '');
      final state = await testState(fs: fs);
      await state.importProject('/fp');
      expect(state.editor!.project.imported, isTrue);
      expect(state.registry.entries.single.imported, isTrue);
    });

    test('update check dedupes and caches', () async {
      final checker = FakeVersionChecker()
        ..gate = Completer<void>();
      final state = await testState(versionChecker: checker);
      final first = state.checkForUpdate();
      final second = state.checkForUpdate();
      expect(identical(first, second), isTrue);
      checker.gate!.complete();
      await first;
      expect(checker.calls, 1);
    });

    test('update check success and failure', () async {
      final checker = FakeVersionChecker()
        ..result = const AppUpdate(
          currentVersion: '1.0.0',
          latestVersion: '2.0.0',
          updateAvailable: true,
          releaseUrl: 'https://x',
        );
      final state = await testState(versionChecker: checker);
      final update = await state.checkForUpdate();
      expect(update!.updateAvailable, isTrue);
      expect(state.update!.latestVersion, '2.0.0');

      final failing = FakeVersionChecker()..error = Exception('down');
      final state2 = await testState(versionChecker: failing);
      expect(await state2.checkForUpdate(), isNull);
    });
  });

  group('EditorState', () {
    EditorState make({MemFs? fs, FakeGit? git}) {
      final fake = git ?? FakeGit();
      return EditorState(
        project: testProject(),
        dir: '/p',
        fs: fs ?? MemFs(),
        gitRun: fake.run,
      );
    }

    test('selection, tabs, device, brightness', () {
      final e = make();
      expect(e.screen.name, 'Home');
      expect(e.selected, isNull);
      e.setLeftTab(1);
      e.setRightTab(2);
      e.setDevice(DevicePreset.tablet);
      e.togglePreviewDark();
      expect(e.leftTab, 1);
      expect(e.rightTab, 2);
      expect(e.device, DevicePreset.tablet);
      expect(e.previewDark, isTrue);
      e.select(e.screen.root.id);
      expect(e.selected, e.screen.root);
      e.select(null);
      expect(e.selected, isNull);
    });

    test('add/remove/move/reorder widgets with undo', () {
      final e = make();
      final col = e.addWidget('column')!;
      expect(col.type, 'column');
      expect(e.selectedId, col.id);
      expect(col.props['spacing'], 0.0);
      final t1 = e.addWidget('text', parentId: col.id)!;
      final t2 = e.addWidget('text', parentId: col.id)!;
      e.setProp(t1.id, 'text', 'hi');
      expect(t1.props['text'], 'hi');
      e.reorder(t2.id, -1);
      expect(
        col.children.map((c) => c.id).toList(),
        [t2.id, t1.id],
      );
      e.reorder(t2.id, -1);
      e.reorder(t1.id, 1);
      e.reorder(t1.id, 1);
      e.moveWidget(t2.id, e.screen.root.parentOf(t2.id)!.id, 0);
      e.removeWidget(t2.id);
      expect(e.screen.root.find(t2.id), isNull);
      expect(e.selectedId, isNull);
      e.undo();
      expect(e.screen.root.find(t2.id), isNotNull);
      expect(e.canUndo, isTrue);
      while (e.canUndo) {
        e.undo();
      }
      e.undo();
      expect(e.dirty, isTrue);
    });

    test('addWidget default parent resolution', () {
      final e = make();
      // root scaffold empty -> goes into root
      final first = e.addWidget('container')!;
      expect(e.screen.root.children.single.id, first.id);
      // selected container (full after one child) -> sibling at root? root is full
      // so falls back to first unbounded container... none -> null
      final leaf = e.addWidget('text', parentId: first.id)!;
      e.select(leaf.id);
      expect(e.addWidget('text'), isNull);
      e.select(null);
      final col = e.addWidget('column') ?? (() {
        // scaffold full; add to an unbounded node inside
        return null;
      })();
      expect(col, isNull);
      final e2 = EditorState(
        project: SunsetProject.create('X'),
        dir: '/q',
        fs: MemFs(),
        gitRun: FakeGit().run,
      );
      final c = e2.addWidget('column')!;
      e2.select(c.id);
      expect(e2.addWidget('text'), isNotNull);
    });

    test('screens', () {
      final e = make();
      e.addScreen('About');
      expect(e.screen.name, 'About');
      final first = e.project.screens.first;
      e.selectScreen(first.id);
      expect(e.screen.id, first.id);
      e.selectScreen(first.id);
      e.renameScreen(first.id, 'Main');
      expect(first.name, 'Main');
      final aboutId = e.project.screens.last.id;
      expect(e.removeScreen(aboutId), isTrue);
      expect(e.removeScreen(e.project.screens.first.id), isFalse);
    });

    test('theme, package, responsive', () {
      final e = make();
      e.setSeedColor(0xFF123456);
      e.setBrightness(ThemeBrightness.dark);
      e.setRadius(24);
      e.setPackageName('com.x.y');
      e.setResponsive(false);
      expect(e.project.theme.seedColor, 0xFF123456);
      expect(e.project.theme.brightness, ThemeBrightness.dark);
      expect(e.project.theme.radius, 24);
      expect(e.project.packageName, 'com.x.y');
      expect(e.screen.responsive, isFalse);
    });

    test('locales and messages', () {
      final e = make();
      e.addLocale('ru');
      e.setMessage('k', 'ru', 'v');
      e.removeMessage('k');
      e.removeLocale('ru');
      expect(e.project.locales, isNot(contains('ru')));
      expect(e.baseLocale, 'en_GB');
    });

    test('save and export', () async {
      final fs = MemFs();
      final e = make(fs: fs);
      e.addWidget('text');
      expect(e.dirty, isTrue);
      await e.save();
      expect(e.dirty, isFalse);
      expect(await fs.exists('/p/project.sunset.json'), isTrue);
      final count = await e.export();
      expect(count, greaterThan(3));
      expect(await fs.exists('/p/lib/main.dart'), isTrue);
    });

    test('git lifecycle', () async {
      final git = FakeGit();
      git.repo = true;
      git.files = [' M a.dart'];
      git.commits = ['abc\x1fsubj\x1fdate'];
      final e = make(git: git);
      await e.gitRefresh();
      expect(e.gitRepo, isTrue);
      expect(e.gitFiles.single.path, 'a.dart');
      expect(e.gitLog.single.hash, 'abc');
      expect(e.gitBranch, 'main');
      await e.gitCommit('msg');
      expect(git.calls.any((c) => c.first == 'commit'), isTrue);
      final notRepo = EditorState(
        project: testProject(),
        dir: '/x',
        fs: MemFs(),
        gitRun: (args, cwd) async =>
            const ProcResult(128, '', 'no git'),
      );
      await notRepo.gitInit();
      expect(notRepo.gitError, contains('no git'));
      await notRepo.gitCommit('x');
      expect(notRepo.gitError, isNotNull);
      await notRepo.gitRefresh();
      expect(notRepo.gitRepo, isFalse);
      final init2 = EditorState(
        project: testProject(),
        dir: '/x',
        fs: MemFs(),
        gitRun: FakeGit().run,
      );
      await init2.gitInit();
      expect(init2.gitRepo, isTrue);
    });
  });
}
