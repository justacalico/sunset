import 'package:flutter/material.dart';

import '../../core/catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../state/editor_state.dart';

const paletteIcons = <String, IconData>{
  'scaffold': Icons.web_asset_outlined,
  'column': Icons.view_column_outlined,
  'row': Icons.view_stream_outlined,
  'stack': Icons.layers_outlined,
  'center': Icons.center_focus_strong_outlined,
  'padding': Icons.space_bar_outlined,
  'expanded': Icons.unfold_more,
  'sizedBox': Icons.crop_square_outlined,
  'container': Icons.square_outlined,
  'card': Icons.rectangle_outlined,
  'listView': Icons.list_outlined,
  'gridView': Icons.grid_view_outlined,
  'divider': Icons.horizontal_rule,
  'spacer': Icons.space_bar,
  'text': Icons.text_fields,
  'icon': Icons.emoji_symbols_outlined,
  'image': Icons.image_outlined,
  'circleAvatar': Icons.account_circle_outlined,
  'button': Icons.smart_button_outlined,
  'textField': Icons.input_outlined,
  'switcher': Icons.toggle_on_outlined,
  'checkbox': Icons.check_box_outlined,
  'slider': Icons.linear_scale_outlined,
  'progress': Icons.hourglass_top_outlined,
};

class PalettePanel extends StatelessWidget {
  final EditorState editor;

  const PalettePanel({super.key, required this.editor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final groups = <String, List<WidgetDef>>{};
    for (final def in catalog) {
      if (def.type == 'scaffold') continue;
      groups.putIfAbsent(def.group, () => []).add(def);
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
            child: Text(
              entry.key == 'layout' ? l10n.groupLayout : l10n.groupContent,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final def in entry.value)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: ListTile(
                key: Key('palette.${def.type}'),
                dense: true,
                leading: Icon(
                  paletteIcons[def.type] ?? Icons.widgets_outlined,
                  size: 20,
                ),
                title: Text(def.type, style: const TextStyle(fontSize: 13)),
                onTap: () => editor.addWidget(def.type),
              ),
            ),
        ],
      ],
    );
  }
}
