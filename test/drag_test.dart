import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunset/core/fs.dart';
import 'package:sunset/state/app_state.dart';
import 'package:sunset/ui/editor/palette.dart';
import 'package:sunset/ui/editor/preview.dart';
import 'package:sunset/ui/editor/tree_panel.dart';

import 'editor_test.dart' show openEditor;
import 'fakes.dart';

Future<void> dragOnto(WidgetTester tester, Offset start, Finder target) async {
  final gesture = await tester.startGesture(start);
  await tester.pump(kLongPressTimeout);
  await gesture.moveBy(const Offset(0, -20));
  await tester.pump();
  await gesture.moveTo(tester.getCenter(target));
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

void main() {
  testWidgets('drag palette widget onto canvas adds it as child', (
    tester,
  ) async {
    final fs = MemFs();
    final state = await testState(fs: fs);
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    final col = editor.addWidget('column')!;
    final target = find
        .descendant(
          of: find.byType(NodePreview),
          matching: find.byType(DragTarget<String>),
        )
        .last;
    await dragOnto(
      tester,
      tester.getCenter(find.byKey(const Key('palette.text'))),
      target,
    );
    expect(col.children.any((c) => c.type == 'text'), isTrue);
  });

  testWidgets('drop widget type onto leaf inserts as sibling', (tester) async {
    final fs = MemFs();
    final state = await testState(fs: fs);
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    final col = editor.addWidget('column')!;
    final text = editor.addWidget('text', parentId: col.id)!;
    editor.drop('new:icon', text);
    expect(col.children.map((c) => c.type).toList(), ['icon', 'text']);
  });

  testWidgets('tree drag reparents node into container', (tester) async {
    final fs = MemFs();
    final state = await testState(fs: fs);
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    await tester.tap(find.byKey(const Key('minitab.1')).first);
    await tester.pump();
    final col = editor.addWidget('column')!;
    final text = editor.addWidget('text')!;
    await tester.pump();
    await dragOnto(
      tester,
      tester.getCenter(find.byKey(Key('tree.${text.id}'))),
      find.byKey(Key('tree.${col.id}')),
    );
    expect(col.children.map((c) => c.id), contains(text.id));
  });

  testWidgets('drop node onto leaf moves it before the leaf', (tester) async {
    final fs = MemFs();
    final state = await testState(fs: fs);
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    final col = editor.addWidget('column')!;
    final a = editor.addWidget('text', parentId: col.id)!;
    final b = editor.addWidget('icon', parentId: col.id)!;
    editor.drop(b.id, a);
    expect(col.children.map((c) => c.id).toList(), [b.id, a.id]);
  });

  testWidgets('drop on full root and same id are no-ops', (tester) async {
    final fs = MemFs();
    final state = await testState(fs: fs);
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    final col = editor.addWidget('column')!;
    editor.drop(col.id, col);
    expect(col.children, isEmpty);
    final text = editor.addWidget('text', parentId: col.id)!;
    final root = editor.screen.root;
    final before = root.children.length;
    editor.drop(text.id, root);
    if (root.children.length > before) {
      expect(root.children.last.id, text.id);
    }
    editor.drop('new:text', root);
    expect(col.children.where((c) => c.type == 'text').length, 2);
    editor.drop(root.id, col);
    expect(root.type, 'scaffold');
  });

  testWidgets('palette tiles and tree rows are draggable', (tester) async {
    final fs = MemFs();
    final state = await testState(fs: fs);
    await state.createProject('/p', 'P');
    final editor = await openEditor(tester, state);
    editor.addWidget('column');
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(PalettePanel),
        matching: find.byType(Draggable<String>),
      ),
      findsWidgets,
    );
    await tester.tap(find.byKey(const Key('minitab.1')).first);
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(TreePanel),
        matching: find.byType(Draggable<String>),
      ),
      findsWidgets,
    );
  });
}
