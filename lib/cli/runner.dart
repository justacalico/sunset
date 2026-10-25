import '../core/catalog.dart';
import '../core/codegen.dart';
import '../core/fs.dart';
import '../core/git_service.dart';
import '../core/importer.dart';
import '../core/model.dart';
import '../core/store.dart';

class CliIo {
  final Fs fs;
  final ProcRun git;
  final void Function(String line) out;
  final void Function(String line) err;
  final String cwd;

  const CliIo({
    required this.fs,
    required this.git,
    required this.out,
    required this.err,
    this.cwd = '.',
  });
}

class CliUsageException implements Exception {
  final String message;

  const CliUsageException(this.message);
}

class _Args {
  final List<String> positional = [];
  final Map<String, String?> options = {};

  _Args(List<String> argv) {
    for (var i = 0; i < argv.length; i++) {
      final arg = argv[i];
      if (arg.startsWith('--')) {
        final eq = arg.indexOf('=');
        if (eq != -1) {
          options[arg.substring(2, eq)] = arg.substring(eq + 1);
        } else if (i + 1 < argv.length && !argv[i + 1].startsWith('--')) {
          options[arg.substring(2)] = argv[++i];
        } else {
          options[arg.substring(2)] = '';
        }
      } else if (arg.startsWith('-') && arg.length == 2) {
        if (i + 1 < argv.length) {
          options[arg.substring(1)] = argv[++i];
        } else {
          options[arg.substring(1)] = '';
        }
      } else {
        positional.add(arg);
      }
    }
  }

  String? opt(String name) => options[name];

  String required(int i, String what) {
    if (i >= positional.length) throw CliUsageException('missing $what');
    return positional[i];
  }
}

const _usage = '''
Sunset - visual Flutter app builder

Usage: sunset <command> [options]

Projects:
  create <dir> [--name N] [--package P] [--description D]   New project
  import <dir>                                             Import an existing Flutter project
  show [--dir D]                                           Project summary
  export [--dir D]                                         Write Flutter sources into the project

Screens:
  screens [--dir D]                                        List screens
  screen add <name> [--dir D]                              Add a screen
  screen remove <id|name> [--dir D]                        Remove a screen
  screen rename <id|name> <name> [--dir D]                 Rename a screen

Widgets:
  widgets                                                  List the widget catalog
  tree [--screen S] [--dir D]                              Print the widget tree
  widget add <type> [--screen S] [--parent ID] [--index N] [--dir D]
  widget remove <id> [--screen S] [--dir D]
  widget move <id> [--parent ID] [--index N] [--screen S] [--dir D]
  widget set <id> <prop> <value> [--screen S] [--dir D]

Theme and strings:
  theme set [--color RRGGBB] [--brightness MODE] [--radius N] [--dir D]
  l10n locales [--dir D]
  l10n add-locale <tag> [--dir D]
  l10n remove-locale <tag> [--dir D]
  l10n keys [--dir D]
  l10n set <key> <locale> <text> [--dir D]
  l10n unset <key> [--dir D]

Git:
  git init|status|log|branch [--dir D]
  git commit -m <message> [--dir D]
''';

Future<int> runCli(List<String> argv, {required CliIo io}) async {
  try {
    return await _dispatch(argv, io);
  } on CliUsageException catch (e) {
    io.err('error: ${e.message}');
    io.err(_usage.trim());
    return 64;
  } catch (e) {
    io.err('error: $e');
    return 1;
  }
}

String _dir(CliIo io, _Args args) {
  final dir = args.opt('dir') ?? '.';
  if (dir.startsWith('/') || dir.startsWith('~') || dir.contains(':')) {
    return dir;
  }
  return io.cwd == '.' ? dir : '${io.cwd}/$dir';
}

String _positionalDir(CliIo io, _Args args, {String? fallback}) {
  final raw =
      args.opt('dir') ??
      (args.positional.isEmpty ? fallback : args.positional[0]) ??
      '.';
  if (raw.startsWith('/') || raw.startsWith('~') || raw.contains(':')) {
    return raw;
  }
  return io.cwd == '.' ? raw : '${io.cwd}/$raw';
}

Future<SunsetProject> _load(CliIo io, _Args args) =>
    ProjectStore(io.fs).load(_dir(io, args));

Future<void> _save(CliIo io, _Args args, SunsetProject project) =>
    ProjectStore(io.fs).save(_dir(io, args), project);

ProjectScreen _screenOf(SunsetProject project, _Args args) {
  final wanted = args.opt('screen');
  if (wanted == null) return project.screens.first;
  final screen = _findScreen(project, wanted);
  if (screen == null) throw CliUsageException('no such screen: $wanted');
  return screen;
}

ProjectScreen? _findScreen(SunsetProject project, String wanted) {
  for (final s in project.screens) {
    if (s.id == wanted || s.name == wanted) return s;
  }
  return null;
}

Future<int> _dispatch(List<String> argv, CliIo io) async {
  if (argv.isEmpty || argv.first == 'help' || argv.first == '--help') {
    io.out(_usage.trim());
    return 0;
  }
  final command = argv.first;
  final args = _Args(argv.sublist(1));

  switch (command) {
    case 'create':
      args.required(0, 'project directory');
      final dir = _positionalDir(io, args);
      final name =
          args.opt('name') ??
          dir.replaceAll('\\', '/').split('/').lastWhere((s) => s.isNotEmpty);
      if (await ProjectStore(io.fs).existsAt(dir)) {
        throw CliUsageException('a Sunset project already exists at $dir');
      }
      final project = await ProjectStore(io.fs).create(
        dir,
        name: name,
        packageName: args.opt('package'),
        description: args.opt('description') ?? '',
      );
      io.out('created ${project.name} at $dir');
      return 0;

    case 'import':
      final result = await importFlutterProject(
        io.fs,
        _positionalDir(io, args),
      );
      io.out('imported ${result.project.name}');
      io.out('${result.dartFiles.length} dart file(s) found');
      return 0;

    case 'show':
      final project = await _load(io, args);
      io.out('name: ${project.name}');
      io.out('package: ${project.packageName}');
      io.out('imported: ${project.imported}');
      io.out('locales: ${project.locales.join(', ')}');
      io.out('screens: ${project.screens.map((s) => s.name).join(', ')}');
      return 0;

    case 'screens':
      final project = await _load(io, args);
      for (final s in project.screens) {
        io.out('${s.id}  ${s.name}');
      }
      return 0;

    case 'screen':
      return _screenCmd(args, io);

    case 'widgets':
      for (final def in catalog) {
        io.out('${def.type}  (${def.group})');
      }
      return 0;

    case 'tree':
      final project = await _load(io, args);
      final screen = _screenOf(project, args);
      void walk(WidgetNode node, String indent) {
        io.out('$indent${node.type} ${node.id}');
        for (final c in node.children) {
          walk(c, '  $indent');
        }
      }

      walk(screen.root, '');
      return 0;

    case 'widget':
      return _widgetCmd(args, io);

    case 'theme':
      return _themeCmd(args, io);

    case 'l10n':
      return _l10nCmd(args, io);

    case 'git':
      return _gitCmd(args, io);

    case 'export':
      final dir = _dir(io, args);
      final project = await ProjectStore(io.fs).load(dir);
      final files = generateProject(project);
      for (final entry in files.entries) {
        await io.fs.write('$dir/${entry.key}', entry.value);
      }
      io.out('exported ${files.length} file(s) to $dir');
      return 0;
  }
  throw CliUsageException('unknown command: $command');
}

Future<int> _screenCmd(_Args args, CliIo io) async {
  final sub = args.required(0, 'screen subcommand');
  final project = await _load(io, args);
  switch (sub) {
    case 'add':
      final screen = project.addScreen(args.required(1, 'screen name'));
      await _save(io, args, project);
      io.out('added screen ${screen.name} (${screen.id})');
      return 0;
    case 'remove':
      final target = args.required(1, 'screen id or name');
      final screen = _findScreen(project, target);
      if (screen == null) throw CliUsageException('no such screen: $target');
      if (!project.removeScreen(screen.id)) {
        throw CliUsageException('cannot remove the last screen');
      }
      await _save(io, args, project);
      io.out('removed screen ${screen.name}');
      return 0;
    case 'rename':
      final target = args.required(1, 'screen id or name');
      final name = args.required(2, 'new name');
      final screen = _findScreen(project, target);
      if (screen == null) throw CliUsageException('no such screen: $target');
      project.renameScreen(screen.id, name);
      await _save(io, args, project);
      io.out('renamed screen to $name');
      return 0;
  }
  throw CliUsageException('unknown screen subcommand: $sub');
}

Future<int> _widgetCmd(_Args args, CliIo io) async {
  final sub = args.required(0, 'widget subcommand');
  final project = await _load(io, args);
  final screen = _screenOf(project, args);
  switch (sub) {
    case 'add':
      final type = args.required(1, 'widget type');
      final def = widgetDef(type);
      if (def == null) throw CliUsageException('unknown widget type: $type');
      final index = args.opt('index');
      final result = project.addWidget(
        screen.id,
        type,
        parentId: args.opt('parent'),
        index: index == null ? null : int.tryParse(index),
      );
      if (result.node == null) {
        throw CliUsageException(result.error ?? 'could not add widget');
      }
      for (final prop in def.props) {
        result.node!.props[prop.name] = prop.value;
      }
      await _save(io, args, project);
      io.out('added $type ${result.node!.id} to ${screen.name}');
      return 0;
    case 'remove':
      final id = args.required(1, 'widget id');
      if (!project.removeWidget(screen.id, id)) {
        throw CliUsageException('widget not found: $id');
      }
      await _save(io, args, project);
      io.out('removed $id');
      return 0;
    case 'move':
      final id = args.required(1, 'widget id');
      final index = args.opt('index');
      if (!project.moveWidget(
        screen.id,
        id,
        parentId: args.opt('parent'),
        index: index == null ? null : int.tryParse(index),
      )) {
        throw CliUsageException('could not move $id');
      }
      await _save(io, args, project);
      io.out('moved $id');
      return 0;
    case 'set':
      final id = args.required(1, 'widget id');
      final prop = args.required(2, 'prop name');
      final raw = args.required(3, 'value');
      final node = screen.root.find(id);
      if (node == null) throw CliUsageException('widget not found: $id');
      final def = widgetDef(node.type);
      PropDef? propDef;
      for (final p in def?.props ?? const <PropDef>[]) {
        if (p.name == prop) propDef = p;
      }
      Object? value = raw;
      if (propDef != null) {
        value = parsePropValue(propDef, raw);
        if (value == null) {
          throw CliUsageException('invalid value "$raw" for $prop');
        }
      }
      project.setProp(screen.id, id, prop, value);
      await _save(io, args, project);
      io.out('set $id.$prop = $value');
      return 0;
  }
  throw CliUsageException('unknown widget subcommand: $sub');
}

Future<int> _themeCmd(_Args args, CliIo io) async {
  final sub = args.required(0, 'theme subcommand');
  if (sub != 'set') throw CliUsageException('unknown theme subcommand: $sub');
  final project = await _load(io, args);
  final color = args.opt('color');
  if (color != null) {
    final parsed = parsePropValue(
      const PropDef('color', PropKind.color, 0),
      color,
    );
    if (parsed == null) throw CliUsageException('invalid color: $color');
    project.theme.seedColor = parsed as int;
  }
  final brightness = args.opt('brightness');
  if (brightness != null) {
    final mode = ThemeBrightness.values.asNameMap()[brightness];
    if (mode == null) {
      throw CliUsageException('invalid brightness: $brightness');
    }
    project.theme.brightness = mode;
  }
  final radius = args.opt('radius');
  if (radius != null) {
    project.theme.radius = double.tryParse(radius) ?? project.theme.radius;
  }
  await _save(io, args, project);
  io.out('theme updated');
  return 0;
}

Future<int> _l10nCmd(_Args args, CliIo io) async {
  final sub = args.required(0, 'l10n subcommand');
  if (sub == 'locales') {
    final project = await _load(io, args);
    for (final tag in project.locales) {
      io.out(tag);
    }
    return 0;
  }
  if (sub == 'keys') {
    final project = await _load(io, args);
    final keys = project.messages.keys.toList()..sort();
    for (final key in keys) {
      io.out(key);
    }
    return 0;
  }
  final project = await _load(io, args);
  switch (sub) {
    case 'add-locale':
      final tag = args.required(1, 'locale tag');
      project.addLocale(tag);
      await _save(io, args, project);
      io.out('added locale $tag');
      return 0;
    case 'remove-locale':
      final tag = args.required(1, 'locale tag');
      if (!project.removeLocale(tag)) {
        throw CliUsageException('cannot remove locale $tag');
      }
      await _save(io, args, project);
      io.out('removed locale $tag');
      return 0;
    case 'set':
      final key = args.required(1, 'key');
      final locale = args.required(2, 'locale');
      final text = args.required(3, 'text');
      if (!project.locales.contains(locale)) {
        throw CliUsageException('unknown locale $locale - add it first');
      }
      project.setMessage(key, locale, text);
      await _save(io, args, project);
      io.out('set $key [$locale]');
      return 0;
    case 'unset':
      final key = args.required(1, 'key');
      if (!project.removeMessage(key)) {
        throw CliUsageException('no such key: $key');
      }
      await _save(io, args, project);
      io.out('removed key $key');
      return 0;
  }
  throw CliUsageException('unknown l10n subcommand: $sub');
}

Future<int> _gitCmd(_Args args, CliIo io) async {
  final sub = args.required(0, 'git subcommand');
  final dir = _dir(io, args);
  final git = GitService(io.git);
  switch (sub) {
    case 'init':
      await git.init(dir);
      io.out('initialized git repository');
      return 0;
    case 'status':
      final files = await git.status(dir);
      if (files.isEmpty) {
        io.out('clean');
      }
      for (final f in files) {
        io.out('${f.status}  ${f.path}');
      }
      return 0;
    case 'log':
      final commits = await git.log(dir);
      for (final c in commits) {
        io.out('${c.hash}  ${c.subject}');
      }
      return 0;
    case 'branch':
      io.out(await git.currentBranch(dir));
      return 0;
    case 'commit':
      final message = args.opt('m') ?? args.opt('message');
      if (message == null || message.isEmpty) {
        throw const CliUsageException('commit requires -m <message>');
      }
      await git.commit(dir, message);
      io.out('committed');
      return 0;
  }
  throw CliUsageException('unknown git subcommand: $sub');
}
