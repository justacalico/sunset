import 'package:flutter/material.dart';

import '../../core/catalog.dart';
import '../../core/model.dart';
import '../../l10n/app_localizations.dart';
import '../../state/editor_state.dart';

const swatchColors = [
  0x00000000,
  0xFFF3813F,
  0xFFE8B44C,
  0xFF8A4FFF,
  0xFF4F8AFF,
  0xFF3FBF7F,
  0xFFE84C6F,
  0xFF212121,
  0xFF9E9E9E,
  0xFFFFFFFF,
];

class InspectorPanel extends StatelessWidget {
  final EditorState editor;

  const InspectorPanel({super.key, required this.editor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final node = editor.selected;
    if (node == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.inspectorEmpty,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    final def = widgetDef(node.type);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                node.type,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            IconButton(
              key: const Key('inspector.up'),
              icon: const Icon(Icons.arrow_upward, size: 18),
              onPressed: () => editor.reorder(node.id, -1),
            ),
            IconButton(
              key: const Key('inspector.down'),
              icon: const Icon(Icons.arrow_downward, size: 18),
              onPressed: () => editor.reorder(node.id, 1),
            ),
            IconButton(
              key: const Key('inspector.delete'),
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => editor.removeWidget(node.id),
            ),
          ],
        ),
        Text(
          node.id,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        for (final prop in def?.props ?? const <PropDef>[])
          _PropEditor(editor: editor, node: node, prop: prop),
        if (def == null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(l10n.unknownWidget),
          ),
      ],
    );
  }
}

class _PropEditor extends StatelessWidget {
  final EditorState editor;
  final WidgetNode node;
  final PropDef prop;

  const _PropEditor({
    required this.editor,
    required this.node,
    required this.prop,
  });

  void _set(Object? value) => editor.setProp(node.id, prop.name, value);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final value = node.props[prop.name] ?? prop.value;
    final label = Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        prop.name,
        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
      ),
    );

    switch (prop.kind) {
      case PropKind.bool:
        return SwitchListTile(
          key: Key('prop.${prop.name}'),
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(prop.name, style: const TextStyle(fontSize: 13)),
          value: value == true,
          onChanged: _set,
        );
      case PropKind.enumProp || PropKind.align || PropKind.icon:
        final items = prop.kind == PropKind.icon ? prop.options : prop.options;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label,
            DropdownButtonFormField<String>(
              key: Key('prop.${prop.name}'),
              initialValue: items.contains('$value') ? '$value' : null,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                for (final option in items)
                  DropdownMenuItem(
                    value: option,
                    child: Text(
                      option.isEmpty ? l10n.noneOption : option,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
              onChanged: (v) => _set(v ?? ''),
            ),
          ],
        );
      case PropKind.color:
        final current = value is int ? value : 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label,
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final color in swatchColors)
                  InkWell(
                    key: Key('prop.${prop.name}.${color.toRadixString(16)}'),
                    onTap: () => _set(color),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: color == 0 ? scheme.surface : Color(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: current == color
                              ? scheme.primary
                              : scheme.outlineVariant,
                          width: current == color ? 2 : 1,
                        ),
                      ),
                      child: color == 0
                          ? Icon(
                              Icons.format_color_reset,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            )
                          : current == color
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        );
      case PropKind.l10nKey:
        final keys = editor.project.messages.keys.toList()..sort();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label,
            DropdownButtonFormField<String>(
              key: Key('prop.${prop.name}'),
              initialValue: keys.contains('$value') ? '$value' : '',
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: '', child: Text(l10n.noneOption)),
                for (final key in keys)
                  DropdownMenuItem(value: key, child: Text(key)),
              ],
              onChanged: (v) => _set(v ?? ''),
            ),
          ],
        );
      case PropKind.string || PropKind.int || PropKind.double:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label,
            _TextProp(
              key: Key('prop.${prop.name}'),
              value: '$value',
              numeric: prop.kind != PropKind.string,
              onSubmit: (raw) {
                if (prop.kind == PropKind.int) {
                  _set(int.tryParse(raw) ?? 0);
                } else if (prop.kind == PropKind.double) {
                  _set(double.tryParse(raw) ?? 0.0);
                } else {
                  _set(raw);
                }
              },
            ),
          ],
        );
    }
  }
}

class _TextProp extends StatefulWidget {
  final String value;
  final bool numeric;
  final ValueChanged<String> onSubmit;

  const _TextProp({
    super.key,
    required this.value,
    required this.numeric,
    required this.onSubmit,
  });

  @override
  State<_TextProp> createState() => _TextPropState();
}

class _TextPropState extends State<_TextProp> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_TextProp old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: const TextStyle(fontSize: 13),
      keyboardType: widget.numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(),
      ),
      onSubmitted: widget.onSubmit,
      onTapOutside: (_) => widget.onSubmit(_controller.text),
    );
  }
}
