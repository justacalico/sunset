import 'package:flutter_test/flutter_test.dart';
import 'package:sunset/cli/runner.dart';
import 'package:sunset/core/fs.dart';
import 'package:sunset/core/git_service.dart';
import 'package:sunset/core/store.dart';

import 'fakes.dart';

class T {
  final fs = MemFs();
  final git = FakeGit();
  final List<String> out = [];
  final List<String> err = [];

  CliIo get io => CliIo(
    fs: fs,
    git: git.run,
    out: out.add,
    err: err.add,
    cwd: '/work',
  );

  Future<int> run(List<String> args) => runCli(args, io: io);
}

void main() {
  test('help and unknown command', () async {
    final t = T();
    expect(await t.run([]), 0);
    expect(t.out.join('\n'), contains('Usage: sunset'));
    expect(await t.run(['help']), 0);
    expect(await t.run(['bogus']), 64);
    expect(t.err.last, contains('Usage: sunset'));
    expect(await t.run(['show']), isNot(0));
  });

  test('create, show, screens lifecycle', () async {
    final t = T();
    expect(await t.run(['create', 'apps/demo', '--name', 'Demo']), 0);
    expect(t.out.last, contains('created Demo'));
    expect(await t.run(['create', 'apps/demo']), 64);
    expect(await t.run(['show', '--dir', 'apps/demo']), 0);
    expect(t.out.join('\n'), contains('name: Demo'));
    expect(await t.run(['screens', '--dir', 'apps/demo']), 0);
    expect(t.out.join('\n'), contains('Home'));

    expect(await t.run(['screen', 'add', 'About', '--dir', 'apps/demo']), 0);
    expect(await t.run(['screen', 'rename', 'About', 'Info', '--dir', 'apps/demo']), 0);
    expect(await t.run(['screen', 'remove', 'Info', '--dir', 'apps/demo']), 0);
    expect(await t.run(['screen', 'remove', 'nope', '--dir', 'apps/demo']), 64);
    expect(await t.run(['screen', 'rename', 'nope', 'x', '--dir', 'apps/demo']), 64);
    expect(await t.run(['screen', 'remove', 'Home', '--dir', 'apps/demo']), 64);
    expect(await t.run(['screen', 'bogus', 'x', '--dir', 'apps/demo']), 64);
  });

  test('widget commands', () async {
    final t = T();
    await t.run(['create', 'p', '--name', 'P']);
    expect(await t.run(['widgets']), 0);
    expect(t.out.join('\n'), contains('text'));

    expect(await t.run(['widget', 'add', 'column', '--dir', 'p']), 0);
    final added = t.out.last;
    expect(added, contains('added column'));
    final colId = added.split(' ').elementAt(2);
    expect(await t.run(['tree', '--dir', 'p']), 0);
    expect(t.out.join('\n'), contains('column'));
    expect(await t.run(['tree', '--screen', 'nope', '--dir', 'p']), 64);

    expect(
      await t.run(['widget', 'add', 'text', '--parent', colId, '--dir', 'p']),
      0,
    );
    final textId = t.out.last.split(' ').elementAt(2);
    expect(await t.run(['widget', 'add', 'nope', '--dir', 'p']), 64);
    expect(
      await t.run(['widget', 'add', 'text', '--parent', 'bad', '--dir', 'p']),
      64,
    );

    expect(await t.run(['widget', 'set', textId, 'text', 'Hi', '--dir', 'p']), 0);
    expect(await t.run(['widget', 'set', 'bad', 'text', 'Hi', '--dir', 'p']), 64);
    expect(
      await t.run(['widget', 'set', textId, 'size', 'notanum', '--dir', 'p']),
      64,
    );
    expect(await t.run(['widget', 'set', textId, 'custom', 'v', '--dir', 'p']), 0);

    await t.run(['widget', 'add', 'text', '--parent', colId, '--dir', 'p']);
    final other = t.out.last.split(' ').elementAt(2);
    expect(
      await t.run(['widget', 'move', other, '--index', '0', '--dir', 'p']),
      0,
    );
    expect(await t.run(['widget', 'move', 'bad', '--dir', 'p']), 64);

    expect(await t.run(['widget', 'remove', other, '--dir', 'p']), 0);
    expect(await t.run(['widget', 'remove', 'bad', '--dir', 'p']), 64);
    expect(await t.run(['widget', 'bogus', 'x', '--dir', 'p']), 64);
  });

  test('theme commands', () async {
    final t = T();
    await t.run(['create', 'p', '--name', 'P']);
    expect(await t.run(['theme', 'set', '--color', 'FF0000', '--dir', 'p']), 0);
    expect(await t.run(['theme', 'set', '--color', 'xyz', '--dir', 'p']), 64);
    expect(await t.run(['theme', 'set', '--brightness', 'dark', '--dir', 'p']), 0);
    expect(await t.run(['theme', 'set', '--brightness', 'x', '--dir', 'p']), 64);
    expect(await t.run(['theme', 'set', '--radius', '20', '--dir', 'p']), 0);
    expect(await t.run(['theme', 'bogus', '--dir', 'p']), 64);
    final p = await ProjectStore(t.fs).load('/work/p');
    expect(p.theme.seedColor, 0xFFFF0000);
    expect(p.theme.brightness.name, 'dark');
    expect(p.theme.radius, 20);
  });

  test('l10n commands', () async {
    final t = T();
    await t.run(['create', 'p', '--name', 'P']);
    expect(await t.run(['l10n', 'locales', '--dir', 'p']), 0);
    expect(t.out.join('\n'), contains('en_GB'));
    expect(await t.run(['l10n', 'add-locale', 'ru', '--dir', 'p']), 0);
    expect(await t.run(['l10n', 'set', 'hi', 'ru', 'privet', '--dir', 'p']), 0);
    expect(await t.run(['l10n', 'set', 'hi', 'xx', 'v', '--dir', 'p']), 64);
    expect(await t.run(['l10n', 'keys', '--dir', 'p']), 0);
    expect(t.out.join('\n'), contains('hi'));
    expect(await t.run(['l10n', 'remove-locale', 'ru', '--dir', 'p']), 0);
    expect(await t.run(['l10n', 'remove-locale', 'en_GB', '--dir', 'p']), 64);
    expect(await t.run(['l10n', 'unset', 'hi', '--dir', 'p']), 0);
    expect(await t.run(['l10n', 'unset', 'hi', '--dir', 'p']), 64);
    expect(await t.run(['l10n', 'bogus', '--dir', 'p']), 64);
  });

  test('git commands', () async {
    final t = T();
    await t.run(['create', 'p', '--name', 'P']);
    t.git.files = [' M a.dart'];
    t.git.commits = ['abc1234\x1finit\x1f2026'];
    expect(await t.run(['git', 'init', '--dir', 'p']), 0);
    expect(await t.run(['git', 'status', '--dir', 'p']), 0);
    expect(t.out.join('\n'), contains('a.dart'));
    expect(await t.run(['git', 'log', '--dir', 'p']), 0);
    expect(t.out.join('\n'), contains('init'));
    expect(await t.run(['git', 'branch', '--dir', 'p']), 0);
    expect(t.out.last, 'main');
    expect(await t.run(['git', 'commit', '-m', 'msg', '--dir', 'p']), 0);
    expect(await t.run(['git', 'commit', '--dir', 'p']), 64);
    t.git.files = [];
    expect(await t.run(['git', 'status', '--dir', 'p']), 0);
    expect(t.out.last, 'clean');
    expect(await t.run(['git', 'bogus', '--dir', 'p']), 64);
    t.git.queue['status'] = [const ProcResult(1, '', 'bad')];
    expect(await t.run(['git', 'status', '--dir', 'p']), 1);
  });

  test('export writes generated files', () async {
    final t = T();
    await t.run(['create', 'p', '--name', 'P']);
    expect(await t.run(['export', '--dir', 'p']), 0);
    expect(t.out.last, contains('exported'));
    expect(await t.fs.exists('/work/p/lib/main.dart'), isTrue);
    expect(await t.fs.exists('/work/p/pubspec.yaml'), isTrue);
    expect(await t.fs.exists('/work/p/lib/screens/home.dart'), isTrue);
  });

  test('import command', () async {
    final t = T();
    await t.fs.write('/work/vis/pubspec.yaml',
        'name: vis\ndependencies:\n  flutter:\n    sdk: flutter\n');
    await t.fs.write('/work/vis/lib/main.dart', '');
    expect(await t.run(['import', 'vis']), 0);
    expect(t.out.join('\n'), contains('imported vis'));
    expect(await t.run(['import']), 1);
  });

  test('missing args and create defaults', () async {
    final t = T();
    expect(await t.run(['create']), 64);
    await t.run(['create', 'solo']);
    final p = await ProjectStore(t.fs).load('/work/solo');
    expect(p.name, 'solo');
    expect(await t.run(['screen']), 64);
    expect(await t.run(['widget']), 64);
    expect(await t.run(['theme']), 64);
    expect(await t.run(['l10n']), 64);
    expect(await t.run(['git']), 64);
  });
}
