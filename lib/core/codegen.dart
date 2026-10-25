import 'model.dart';

String snakeName(String name) {
  final out = name
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return out.isEmpty ? 'app' : out;
}

String pascalName(String name) {
  final parts = snakeName(name).split('_');
  return parts
      .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
      .join();
}

String _str(Object? value) {
  final s = '${value ?? ''}';
  return "'${s.replaceAll('\\', '\\\\').replaceAll("'", "\\'").replaceAll('\$', '\\\$').replaceAll('\n', '\\n')}'";
}

String _color(Object? value) {
  final v = value is int ? value : (value is num ? value.toInt() : 0);
  return 'Color(0x${v.toRadixString(16).padLeft(8, '0').toUpperCase()})';
}

int _colorInt(Object? value) =>
    value is int ? value : (value is num ? value.toInt() : 0);

double _double(Object? value, [double fallback = 0]) =>
    value is num ? value.toDouble() : fallback;

int _int(Object? value, [int fallback = 0]) =>
    value is num ? value.toInt() : fallback;

bool _bool(Object? value, [bool fallback = false]) =>
    value is bool ? value : fallback;

String _textOf(WidgetNode node, String literal, String key) {
  final k = '${node.props[key] ?? ''}';
  if (k.isNotEmpty) return "SunsetL10n.of(context).t('${_esc(k)}')";
  return _str(node.props[literal]);
}

String _esc(String s) => s.replaceAll("'", "\\'");

Map<String, String> generateProject(SunsetProject project) {
  final files = <String, String>{};
  if (!project.imported) {
    files['pubspec.yaml'] = _pubspec(project);
    files['analysis_options.yaml'] =
        'include: package:flutter_lints/flutter.yaml\n';
    files['lib/main.dart'] = _main(project);
    files['.gitignore'] =
        '.dart_tool/\nbuild/\n.flutter-plugins*\n.packages\n.idea/\n*.iml\n';
  }
  files['lib/sunset_l10n.dart'] = _l10n(project);
  for (final screen in project.screens) {
    files['lib/screens/${snakeName(screen.name)}.dart'] = _screen(project, screen);
  }
  return files;
}

String _pubspec(SunsetProject project) => '''
name: ${snakeName(project.name)}
description: "${project.description.replaceAll('"', '\\"')}"
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: ^3.13.5

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  generate: true
  uses-material-design: true
''';

String _localeExpr(String tag) {
  final parts = tag.split('_');
  if (parts.length == 1) return "Locale('${parts[0]}')";
  if (parts[0] == 'zh') {
    return "Locale.fromSubtags(languageCode: 'zh', scriptCode: '${parts[1]}')";
  }
  return "Locale('${parts[0]}', '${parts[1]}')";
}

String _main(SunsetProject project) {
  final theme = project.theme;
  final seed = _color(theme.seedColor);
  final mode = switch (theme.brightness) {
    ThemeBrightness.system => 'ThemeMode.system',
    ThemeBrightness.light => 'ThemeMode.light',
    ThemeBrightness.dark => 'ThemeMode.dark',
  };
  final home = pascalName(project.screens.first.name);
  return '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/${snakeName(project.screens.first.name)}.dart';
import 'sunset_l10n.dart';

void main() => runApp(const ${pascalName(project.name)}App());

class ${pascalName(project.name)}App extends StatelessWidget {
  const ${pascalName(project.name)}App({super.key});

  ThemeData _theme(Brightness brightness) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: $seed,
      brightness: brightness,
    ),
    useMaterial3: true,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ${_str(project.name)},
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: $mode,
      supportedLocales: SunsetL10n.supportedLocales,
      localizationsDelegates: SunsetL10n.localizationsDelegates,
      home: const ${home}Screen(),
    );
  }
}
''';
}

String _l10n(SunsetProject project) {
  final locales = project.locales.isEmpty ? ['en_GB'] : project.locales;
  final base = locales.first;
  final buf = StringBuffer('''
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class SunsetL10n {
  final Locale locale;

  const SunsetL10n(this.locale);

  static const supportedLocales = [
''');
  for (final tag in locales) {
    buf.writeln('    ${_localeExpr(tag)},');
  }
  buf.writeln(''');
  static const localizationsDelegates = <LocalizationsDelegate<Object?>>[
    _SunsetL10nDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static SunsetL10n of(BuildContext context) =>
      Localizations.of<SunsetL10n>(context, SunsetL10n)!;

  static const _messages = <String, Map<String, String>>{
''');
  final keys = project.messages.keys.toList()..sort();
  for (final key in keys) {
    buf.writeln('    ${_str(key)}: {');
    for (final tag in locales) {
      final text = project.messages[key]?[tag];
      if (text != null) buf.writeln('      ${_str(tag)}: ${_str(text)},');
    }
    buf.writeln('    },');
  }
  buf.writeln('''
  };

  String t(String key) =>
      _messages[key]?[locale.toString()] ??
      _messages[key]?[${_str(base)}] ??
      key;
}

class _SunsetL10nDelegate extends LocalizationsDelegate<SunsetL10n> {
  const _SunsetL10nDelegate();

  @override
  bool isSupported(Locale locale) =>
      SunsetL10n.supportedLocales.any(
        (l) => l.languageCode == locale.languageCode,
      );

  @override
  Future<SunsetL10n> load(Locale locale) async => SunsetL10n(locale);

  @override
  bool shouldReload(_SunsetL10nDelegate old) => false;
}
''');
  return buf.toString();
}

String _screen(SunsetProject project, ProjectScreen screen) {
  final body = _emit(screen.root.children.isEmpty
      ? null
      : screen.root.children.first, 6);
  final appBar = _bool(screen.root.props['showAppBar'], true)
      ? '''appBar: AppBar(
        title: Text(${_textOf(screen.root, 'title', 'titleKey')}),
        centerTitle: ${_bool(screen.root.props['centerTitle'], true)},
      ),'''
      : '';
  final bodyExpr = screen.responsive
      ? '''LayoutBuilder(
        builder: (context, constraints) {
          final pad = constraints.maxWidth > 900
              ? 48.0
              : constraints.maxWidth > 600
                  ? 28.0
                  : 16.0;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: $body,
          );
        },
      )'''
      : body;
  return '''
import 'package:flutter/material.dart';

import '../sunset_l10n.dart';

class ${pascalName(screen.name)}Screen extends StatelessWidget {
  const ${pascalName(screen.name)}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      $appBar
      body: $bodyExpr,
    );
  }
}
''';
}

String _emit(WidgetNode? node, int indent) {
  if (node == null) return 'const SizedBox.shrink()';
  final p = node.props;
  WidgetNode? childAt(int i) => i < node.children.length ? node.children[i] : null;
  final only = _emit(childAt(0), indent + 2);
  String many(String ctor, String joiner) {
    final kids = [for (final c in node.children) _emit(c, indent + 2)];
    if (kids.isEmpty) return 'const $ctor(children: [])';
    return '$ctor(${joiner}children: [${kids.map((k) => '\n${'  ' * (indent + 1)}$k').join(',')},\n${'  ' * indent}],)';
  }

  List<String> spaced(double gap, bool horizontal) {
    final kids = <String>[];
    for (var i = 0; i < node.children.length; i++) {
      if (i > 0 && gap > 0) {
        kids.add(horizontal
            ? 'SizedBox(width: $gap)'
            : 'SizedBox(height: $gap)');
      }
      kids.add(_emit(node.children[i], indent + 2));
    }
    return kids;
  }

  switch (node.type) {
    case 'scaffold':
      return only;
    case 'column':
      final gap = _double(p['spacing']);
      return 'Column(mainAxisAlignment: MainAxisAlignment.${p['mainAxis'] ?? 'start'}, crossAxisAlignment: CrossAxisAlignment.${p['crossAxis'] ?? 'center'}, children: [${spaced(gap, false).map((k) => '\n${'  ' * (indent + 1)}$k').join(',')},\n${'  ' * indent}])';
    case 'row':
      final gap = _double(p['spacing']);
      return 'Row(mainAxisAlignment: MainAxisAlignment.${p['mainAxis'] ?? 'start'}, crossAxisAlignment: CrossAxisAlignment.${p['crossAxis'] ?? 'center'}, children: [${spaced(gap, true).map((k) => '\n${'  ' * (indent + 1)}$k').join(',')},\n${'  ' * indent}])';
    case 'stack':
      return many('Stack', 'alignment: Alignment.${p['alignment'] ?? 'topLeft'}, ');
    case 'center':
      return 'Center(child: $only)';
    case 'padding':
      return 'Padding(padding: EdgeInsets.all(${_double(p['padding'], 16)}), child: $only)';
    case 'expanded':
      return 'Expanded(flex: ${_int(p['flex'], 1)}, child: $only)';
    case 'sizedBox':
      final w = _double(p['width']);
      final h = _double(p['height']);
      return 'SizedBox(${w > 0 ? 'width: $w, ' : ''}${h > 0 ? 'height: $h, ' : ''}child: $only)';
    case 'container':
      final w = _double(p['width']);
      final h = _double(p['height']);
      final color = _colorInt(p['color']);
      final radius = _double(p['radius']);
      final pad = _double(p['padding']);
      final deco = <String>[
        if (color != 0) 'color: ${_color(color)}',
        if (radius > 0) 'borderRadius: BorderRadius.circular($radius)',
      ];
      return 'Container('
          '${w > 0 ? 'width: $w, ' : ''}${h > 0 ? 'height: $h, ' : ''}'
          '${pad > 0 ? 'padding: EdgeInsets.all($pad), ' : ''}'
          'alignment: Alignment.${p['align'] ?? 'topLeft'}, '
          '${deco.isEmpty ? '' : 'decoration: BoxDecoration(${deco.join(', ')}), '}'
          'child: $only)';
    case 'card':
      return 'Card(elevation: ${_double(p['elevation'], 1)}, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(${_double(p['radius'], 12)})), child: Padding(padding: EdgeInsets.all(${_double(p['padding'], 16)}), child: $only))';
    case 'listView':
      final gap = _double(p['spacing']);
      final pad = _double(p['padding']);
      final h = _double(p['height']);
      final list = 'ListView(${pad > 0 ? 'padding: EdgeInsets.all($pad), ' : ''}children: [${spaced(gap, false).map((k) => '\n${'  ' * (indent + 1)}$k').join(',')},\n${'  ' * indent}])';
      return h > 0 ? 'SizedBox(height: $h, child: $list)' : 'Expanded(child: $list)';
    case 'gridView':
      final gap = _double(p['spacing'], 8);
      final h = _double(p['height']);
      final grid = 'GridView.count(crossAxisCount: ${_int(p['columns'], 2).clamp(1, 24)}, mainAxisSpacing: $gap, crossAxisSpacing: $gap, children: [${node.children.map((c) => '\n${'  ' * (indent + 1)}${_emit(c, indent + 2)}').join(',')},\n${'  ' * indent}])';
      return h > 0 ? 'SizedBox(height: $h, child: $grid)' : 'Expanded(child: $grid)';
    case 'divider':
      return 'Divider(thickness: ${_double(p['thickness'], 1)})';
    case 'spacer':
      return 'Spacer(flex: ${_int(p['flex'], 1)})';
    case 'text':
      final color = _colorInt(p['color']);
      return 'Text(${_textOf(node, 'text', 'textKey')}, textAlign: TextAlign.${p['align'] ?? 'left'}, style: TextStyle(fontSize: ${_double(p['size'], 14)}${_bool(p['bold']) ? ', fontWeight: FontWeight.bold' : ''}${color != 0 ? ', color: ${_color(color)}' : ''}))';
    case 'icon':
      final color = _colorInt(p['color']);
      return 'Icon(Icons.${p['icon'] ?? 'star'}, size: ${_double(p['size'], 24)}${color != 0 ? ', color: ${_color(color)}' : ''})';
    case 'image':
      final url = '${p['url'] ?? ''}';
      final h = _double(p['height'], 160);
      if (url.isEmpty) {
        return 'Container(height: $h, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.image_outlined)))';
      }
      return 'Image.network(${_str(url)}, height: $h, fit: BoxFit.${p['fit'] ?? 'cover'})';
    case 'circleAvatar':
      final color = _colorInt(p['color']);
      return 'CircleAvatar(radius: ${_double(p['radius'], 24)}${color != 0 ? ', backgroundColor: ${_color(color)}' : ''}, child: Icon(Icons.${p['icon'] ?? 'person'}))';
    case 'button':
      final icon = '${p['icon'] ?? ''}';
      final ctor = switch ('${p['style'] ?? 'filled'}') {
        'tonal' => 'FilledButton.tonal',
        'outlined' => 'OutlinedButton',
        'text' => 'TextButton',
        _ => 'FilledButton',
      };
      if (icon.isNotEmpty) {
        return '$ctor.icon(onPressed: () {}, icon: const Icon(Icons.$icon), label: Text(${_textOf(node, 'label', 'labelKey')}))';
      }
      return '$ctor(onPressed: () {}, child: Text(${_textOf(node, 'label', 'labelKey')}))';
    case 'textField':
      final label = '${p['label'] ?? ''}';
      final labelKey = '${p['labelKey'] ?? ''}';
      return 'TextField(decoration: InputDecoration(isDense: ${_bool(p['dense'], true)}, border: const OutlineInputBorder(), hintText: ${_textOf(node, 'hint', 'hintKey')}${label.isNotEmpty || labelKey.isNotEmpty ? ', labelText: ${_textOf(node, 'label', 'labelKey')}' : ''}))';
    case 'switcher':
      return 'SwitchListTile(value: ${_bool(p['value'], true)}, onChanged: (_) {}, title: Text(${_textOf(node, 'label', 'labelKey')}))';
    case 'checkbox':
      return 'CheckboxListTile(value: ${_bool(p['value'])}, onChanged: (_) {}, title: Text(${_textOf(node, 'label', 'labelKey')}))';
    case 'slider':
      return 'Slider(value: ${_double(p['value'], 0.5)}, onChanged: (_) {})';
    case 'progress':
      return 'LinearProgressIndicator(value: ${_double(p['value'], 0.5)})';
    default:
      return 'const SizedBox.shrink()';
  }
}
