import 'package:flutter/material.dart';

import '../../core/model.dart';

const iconMap = <String, IconData>{
  'add': Icons.add,
  'arrow_back': Icons.arrow_back,
  'arrow_forward': Icons.arrow_forward,
  'calendar_today': Icons.calendar_today,
  'camera': Icons.camera,
  'chat': Icons.chat,
  'check': Icons.check,
  'cloud': Icons.cloud,
  'delete': Icons.delete,
  'download': Icons.download,
  'edit': Icons.edit,
  'email': Icons.email,
  'favorite': Icons.favorite,
  'folder': Icons.folder,
  'home': Icons.home,
  'lock': Icons.lock,
  'map': Icons.map,
  'menu': Icons.menu,
  'mic': Icons.mic,
  'music_note': Icons.music_note,
  'notifications': Icons.notifications,
  'pause': Icons.pause,
  'person': Icons.person,
  'phone': Icons.phone,
  'photo': Icons.photo,
  'play_arrow': Icons.play_arrow,
  'search': Icons.search,
  'settings': Icons.settings,
  'share': Icons.share,
  'shopping_cart': Icons.shopping_cart,
  'star': Icons.star,
  'upload': Icons.upload,
  'videocam': Icons.videocam,
  'visibility': Icons.visibility,
  'wb_sunny': Icons.wb_sunny,
  'dark_mode': Icons.dark_mode,
};

IconData iconFor(String name) => iconMap[name] ?? Icons.help_outline;

const alignmentMap = <String, Alignment>{
  'topLeft': Alignment.topLeft,
  'topCenter': Alignment.topCenter,
  'topRight': Alignment.topRight,
  'centerLeft': Alignment.centerLeft,
  'center': Alignment.center,
  'centerRight': Alignment.centerRight,
  'bottomLeft': Alignment.bottomLeft,
  'bottomCenter': Alignment.bottomCenter,
  'bottomRight': Alignment.bottomRight,
};

const mainAxisMap = <String, MainAxisAlignment>{
  'start': MainAxisAlignment.start,
  'center': MainAxisAlignment.center,
  'end': MainAxisAlignment.end,
  'spaceBetween': MainAxisAlignment.spaceBetween,
  'spaceAround': MainAxisAlignment.spaceAround,
  'spaceEvenly': MainAxisAlignment.spaceEvenly,
};

const crossAxisMap = <String, CrossAxisAlignment>{
  'start': CrossAxisAlignment.start,
  'center': CrossAxisAlignment.center,
  'end': CrossAxisAlignment.end,
  'stretch': CrossAxisAlignment.stretch,
};

const textAlignMap = <String, TextAlign>{
  'left': TextAlign.left,
  'center': TextAlign.center,
  'right': TextAlign.right,
  'justify': TextAlign.justify,
};

const fitMap = <String, BoxFit>{
  'contain': BoxFit.contain,
  'cover': BoxFit.cover,
  'fill': BoxFit.fill,
  'fitHeight': BoxFit.fitHeight,
  'fitWidth': BoxFit.fitWidth,
  'none': BoxFit.none,
};

class NodePreview extends StatelessWidget {
  final SunsetProject project;
  final ProjectScreen screen;
  final String? selectedId;
  final ValueChanged<String>? onSelect;
  final bool responsive;

  const NodePreview({
    super.key,
    required this.project,
    required this.screen,
    this.selectedId,
    this.onSelect,
    this.responsive = false,
  });

  @override
  Widget build(BuildContext context) => buildNode(context, screen.root);

  static double _d(Object? v, [double fallback = 0]) =>
      v is num ? v.toDouble() : fallback;

  static int _i(Object? v, [int fallback = 0]) =>
      v is num ? v.toInt() : fallback;

  static bool _b(Object? v, [bool fallback = false]) =>
      v is bool ? v : fallback;

  Color? _color(Object? v) {
    final value = _i(v);
    return value == 0 ? null : Color(value);
  }

  String _text(WidgetNode node, String literal, String key) {
    final k = '${node.props[key] ?? ''}';
    if (k.isEmpty) return '${node.props[literal] ?? ''}';
    return project.message(k, _baseLocale()) ?? k;
  }

  String _baseLocale() =>
      project.locales.isEmpty ? 'en_GB' : project.locales.first;

  Widget buildNode(BuildContext context, WidgetNode node) {
    var child = _build(context, node);
    final flexChild = node.type == 'expanded' || node.type == 'spacer';
    if (onSelect != null && !flexChild) {
      final selected = node.id == selectedId;
      child = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onSelect!(node.id),
        child: selected
            ? Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: child,
              )
            : child,
      );
    }
    return child;
  }

  Widget? _only(BuildContext context, WidgetNode node) =>
      node.children.isEmpty ? null : buildNode(context, node.children.first);

  List<Widget> _spaced(
    BuildContext context,
    WidgetNode node,
    double gap,
    bool horizontal,
  ) {
    final kids = <Widget>[];
    for (var i = 0; i < node.children.length; i++) {
      if (i > 0 && gap > 0) {
        kids.add(
          SizedBox(width: horizontal ? gap : 0, height: horizontal ? 0 : gap),
        );
      }
      kids.add(buildNode(context, node.children[i]));
    }
    return kids;
  }

  Widget _build(BuildContext context, WidgetNode node) {
    final p = node.props;
    switch (node.type) {
      case 'scaffold':
        return Scaffold(
          appBar: _b(p['showAppBar'], true)
              ? AppBar(
                  title: Text(_text(node, 'title', 'titleKey')),
                  centerTitle: _b(p['centerTitle'], true),
                )
              : null,
          body: responsive
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final pad = constraints.maxWidth > 900
                        ? 48.0
                        : constraints.maxWidth > 600
                        ? 28.0
                        : 16.0;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: pad),
                      child: _only(context, node) ?? const SizedBox.shrink(),
                    );
                  },
                )
              : _only(context, node) ?? const SizedBox.shrink(),
        );
      case 'column':
        return Column(
          mainAxisAlignment:
              mainAxisMap['${p['mainAxis']}'] ?? MainAxisAlignment.start,
          crossAxisAlignment:
              crossAxisMap['${p['crossAxis']}'] ?? CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: _spaced(context, node, _d(p['spacing']), false),
        );
      case 'row':
        return Row(
          mainAxisAlignment:
              mainAxisMap['${p['mainAxis']}'] ?? MainAxisAlignment.start,
          crossAxisAlignment:
              crossAxisMap['${p['crossAxis']}'] ?? CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: _spaced(context, node, _d(p['spacing']), true),
        );
      case 'stack':
        return Stack(
          alignment: alignmentMap['${p['alignment']}'] ?? Alignment.topLeft,
          children: [for (final c in node.children) buildNode(context, c)],
        );
      case 'center':
        return Center(child: _only(context, node));
      case 'padding':
        return Padding(
          padding: EdgeInsets.all(_d(p['padding'], 16)),
          child: _only(context, node),
        );
      case 'expanded':
        return Expanded(
          flex: _i(p['flex'], 1),
          child: _only(context, node) ?? const SizedBox.shrink(),
        );
      case 'sizedBox':
        final w = _d(p['width']);
        final h = _d(p['height']);
        return SizedBox(
          width: w > 0 ? w : null,
          height: h > 0 ? h : null,
          child: _only(context, node),
        );
      case 'container':
        final w = _d(p['width']);
        final h = _d(p['height']);
        final radius = _d(p['radius']);
        final pad = _d(p['padding']);
        final color = _color(p['color']);
        return Container(
          width: w > 0 ? w : null,
          height: h > 0 ? h : null,
          padding: pad > 0 ? EdgeInsets.all(pad) : null,
          alignment: alignmentMap['${p['align']}'] ?? Alignment.topLeft,
          decoration: BoxDecoration(
            color: color,
            borderRadius: radius > 0 ? BorderRadius.circular(radius) : null,
          ),
          child: _only(context, node),
        );
      case 'card':
        return Card(
          elevation: _d(p['elevation'], 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_d(p['radius'], 12)),
          ),
          child: Padding(
            padding: EdgeInsets.all(_d(p['padding'], 16)),
            child: _only(context, node),
          ),
        );
      case 'listView':
        final pad = _d(p['padding']);
        return SizedBox(
          height: _d(p['height'], 240),
          child: ListView(
            padding: pad > 0 ? EdgeInsets.all(pad) : EdgeInsets.zero,
            children: _spaced(context, node, _d(p['spacing']), false),
          ),
        );
      case 'gridView':
        final gap = _d(p['spacing'], 8);
        return SizedBox(
          height: _d(p['height'], 240),
          child: GridView.count(
            crossAxisCount: _i(p['columns'], 2).clamp(1, 24),
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            children: [for (final c in node.children) buildNode(context, c)],
          ),
        );
      case 'divider':
        return Divider(thickness: _d(p['thickness'], 1));
      case 'spacer':
        return Spacer(flex: _i(p['flex'], 1));
      case 'text':
        return Text(
          _text(node, 'text', 'textKey'),
          textAlign: textAlignMap['${p['align']}'] ?? TextAlign.left,
          style: TextStyle(
            fontSize: _d(p['size'], 14),
            fontWeight: _b(p['bold']) ? FontWeight.bold : null,
            color: _color(p['color']),
          ),
        );
      case 'icon':
        return Icon(
          iconFor('${p['icon']}'),
          size: _d(p['size'], 24),
          color: _color(p['color']),
        );
      case 'image':
        final url = '${p['url'] ?? ''}';
        final h = _d(p['height'], 160);
        if (url.isEmpty) {
          return Container(
            height: h,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Icon(Icons.image_outlined)),
          );
        }
        return Image.network(
          url,
          height: h,
          fit: fitMap['${p['fit']}'] ?? BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            height: h,
            color: Colors.black12,
            child: const Center(child: Icon(Icons.broken_image_outlined)),
          ),
        );
      case 'circleAvatar':
        return CircleAvatar(
          radius: _d(p['radius'], 24),
          backgroundColor: _color(p['color']),
          child: Icon(iconFor('${p['icon']}')),
        );
      case 'button':
        final icon = '${p['icon'] ?? ''}';
        final label = Text(_text(node, 'label', 'labelKey'));
        void noop() {}
        return switch ('${p['style'] ?? 'filled'}') {
          'tonal' =>
            icon.isEmpty
                ? FilledButton.tonal(onPressed: noop, child: label)
                : FilledButton.tonalIcon(
                    onPressed: noop,
                    icon: Icon(iconFor(icon)),
                    label: label,
                  ),
          'outlined' =>
            icon.isEmpty
                ? OutlinedButton(onPressed: noop, child: label)
                : OutlinedButton.icon(
                    onPressed: noop,
                    icon: Icon(iconFor(icon)),
                    label: label,
                  ),
          'text' =>
            icon.isEmpty
                ? TextButton(onPressed: noop, child: label)
                : TextButton.icon(
                    onPressed: noop,
                    icon: Icon(iconFor(icon)),
                    label: label,
                  ),
          _ =>
            icon.isEmpty
                ? FilledButton(onPressed: noop, child: label)
                : FilledButton.icon(
                    onPressed: noop,
                    icon: Icon(iconFor(icon)),
                    label: label,
                  ),
        };
      case 'textField':
        final label = '${p['label'] ?? ''}';
        final labelKey = '${p['labelKey'] ?? ''}';
        return TextField(
          decoration: InputDecoration(
            isDense: _b(p['dense'], true),
            border: const OutlineInputBorder(),
            hintText: _text(node, 'hint', 'hintKey'),
            labelText: label.isNotEmpty || labelKey.isNotEmpty
                ? _text(node, 'label', 'labelKey')
                : null,
          ),
        );
      case 'switcher':
        return SwitchListTile(
          value: _b(p['value'], true),
          onChanged: (_) {},
          title: Text(_text(node, 'label', 'labelKey')),
        );
      case 'checkbox':
        return CheckboxListTile(
          value: _b(p['value']),
          onChanged: (_) {},
          title: Text(_text(node, 'label', 'labelKey')),
        );
      case 'slider':
        return Slider(value: _d(p['value'], 0.5), onChanged: (_) {});
      case 'progress':
        return LinearProgressIndicator(value: _d(p['value'], 0.5));
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.red.withValues(alpha: 0.2),
          child: Text('? ${node.type}'),
        );
    }
  }
}
