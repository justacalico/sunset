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

    Widget row(WidgetNode node, int depth) {
      final selected = node.id == editor.selectedId;
      final content = Material(
        color: selected ? scheme.secondaryContainer : Colors.transparent,
        child: InkWell(
          onTap: () => editor.select(node.id),
          child: Padding(
            padding: EdgeInsets.only(left: 8.0 + depth * 14, top: 7, bottom: 7),
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
      );
      final body = node.id == editor.screen.root.id
          ? content
          : Draggable<String>(
              data: node.id,
              feedback: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(node.type, style: const TextStyle(fontSize: 13)),
                ),
              ),
              childWhenDragging: Opacity(opacity: 0.4, child: content),
              child: content,
            );
      return DragTarget<String>(
        onAcceptWithDetails: (details) => editor.drop(details.data, node),
        builder: (context, candidates, rejected) => Container(
          decoration: candidates.isNotEmpty
              ? BoxDecoration(
                  border: Border.all(color: scheme.primary, width: 2),
                )
              : null,
          child: body,
        ),
      );
    }

    void walk(WidgetNode node, int depth) {
      rows.add(Container(key: Key('tree.${node.id}'), child: row(node, depth)));
      for (final c in node.children) {
        walk(c, depth + 1);
      }
    }

    walk(editor.screen.root, 0);
    return ListView(children: rows);
  }
}
