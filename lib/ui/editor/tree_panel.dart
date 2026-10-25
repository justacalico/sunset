import 'package:flutter/material.dart';

import '../../core/model.dart';
import '../../state/editor_state.dart';

class TreePanel extends StatelessWidget {
  final EditorState editor;

  const TreePanel({super.key, required this.editor});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rows = <Widget>[];

    void walk(WidgetNode node, int depth) {
      final selected = node.id == editor.selectedId;
      rows.add(
        Material(
          key: Key('tree.${node.id}'),
          color: selected ? scheme.secondaryContainer : Colors.transparent,
          child: InkWell(
            onTap: () => editor.select(node.id),
            child: Padding(
              padding: EdgeInsets.only(
                left: 8.0 + depth * 14,
                top: 7,
                bottom: 7,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.subdirectory_arrow_right,
                    size: 12,
                    color: depth == 0
                        ? Colors.transparent
                        : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      node.type,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    node.id,
                    style: TextStyle(
                      fontSize: 10,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      );
      for (final c in node.children) {
        walk(c, depth + 1);
      }
    }

    walk(editor.screen.root, 0);
    return ListView(children: rows);
  }
}
