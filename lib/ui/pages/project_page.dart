import 'package:flutter/material.dart';

import '../../core/model.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../state/editor_state.dart';
import '../editor/inspector.dart';
import '../editor/palette.dart';
import '../editor/panels.dart';
import '../editor/preview.dart';
import '../editor/tree_panel.dart';

class ProjectPage extends StatelessWidget {
  final EditorState editor;

  const ProjectPage({super.key, required this.editor});

  static const deviceSizes = {
    DevicePreset.phone: Size(390, 700),
    DevicePreset.tablet: Size(700, 1000),
    DevicePreset.desktop: Size(1100, 640),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: editor,
      builder: (context, _) {
        return Column(
          children: [
            _Toolbar(editor: editor, l10n: l10n),
            const Divider(height: 1),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        _MiniTabs(
                          index: editor.leftTab,
                          labels: [l10n.panelWidgets, l10n.panelTree],
                          onTap: editor.setLeftTab,
                        ),
                        Expanded(
                          child: editor.leftTab == 0
                              ? PalettePanel(editor: editor)
                              : TreePanel(editor: editor),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Container(
                      color: scheme.surfaceContainerLowest,
                      child: _Canvas(editor: editor),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  SizedBox(
                    width: 300,
                    child: Column(
                      children: [
                        _MiniTabs(
                          index: editor.rightTab,
                          labels: [
                            l10n.panelProps,
                            l10n.panelTheme,
                            l10n.panelStrings,
                            l10n.panelGit,
                            l10n.panelExport,
                          ],
                          onTap: editor.setRightTab,
                        ),
                        Expanded(
                          child: switch (editor.rightTab) {
                            0 => InspectorPanel(editor: editor),
                            1 => ThemePanel(editor: editor),
                            2 => StringsPanel(editor: editor),
                            3 => GitPanel(editor: editor),
                            _ => ExportPanel(editor: editor),
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MiniTabs extends StatelessWidget {
  final int index;
  final List<String> labels;
  final ValueChanged<int> onTap;

  const _MiniTabs({
    required this.index,
    required this.labels,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                key: Key('minitab.$i'),
                onTap: () => onTap(i),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: i == index
                            ? scheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          i == index ? FontWeight.w600 : FontWeight.normal,
                      color: i == index
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  final EditorState editor;
  final AppLocalizations l10n;

  const _Toolbar({required this.editor, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            key: const Key('editor.back'),
            icon: const Icon(Icons.arrow_back, size: 20),
            tooltip: l10n.backToDashboard,
            onPressed: state.closeProject,
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final s in editor.project.screens)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 8,
                    ),
                    child: InputChip(
                      key: Key('screen.${s.id}'),
                      label: Text(s.name),
                      selected: s.id == editor.screen.id,
                      onPressed: () => editor.selectScreen(s.id),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: editor.project.screens.length > 1
                          ? () => editor.removeScreen(s.id)
                          : null,
                    ),
                  ),
                IconButton(
                  key: const Key('screen.add'),
                  icon: const Icon(Icons.add, size: 18),
                  tooltip: l10n.addScreen,
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => _ScreenDialog(editor: editor),
                  ),
                ),
                IconButton(
                  key: const Key('screen.rename'),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: l10n.renameScreen,
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) =>
                        _ScreenDialog(editor: editor, rename: editor.screen),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('editor.undo'),
            icon: const Icon(Icons.undo, size: 18),
            onPressed: editor.canUndo ? editor.undo : null,
          ),
          IconButton(
            key: const Key('editor.save'),
            icon: Icon(
              Icons.save_outlined,
              size: 18,
              color: editor.dirty ? scheme.primary : null,
            ),
            tooltip: l10n.saveProject,
            onPressed: () async {
              await editor.save();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.projectSaved)),
                );
              }
            },
          ),
          SegmentedButton<DevicePreset>(
            key: const Key('editor.device'),
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
            segments: const [
              ButtonSegment(
                value: DevicePreset.phone,
                icon: Icon(Icons.phone_iphone, size: 16),
              ),
              ButtonSegment(
                value: DevicePreset.tablet,
                icon: Icon(Icons.tablet_mac, size: 16),
              ),
              ButtonSegment(
                value: DevicePreset.desktop,
                icon: Icon(Icons.desktop_mac_outlined, size: 16),
              ),
            ],
            selected: {editor.device},
            onSelectionChanged: (v) => editor.setDevice(v.first),
          ),
          IconButton(
            key: const Key('editor.brightness'),
            icon: Icon(
              editor.previewDark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              size: 18,
            ),
            onPressed: editor.togglePreviewDark,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _ScreenDialog extends StatefulWidget {
  final EditorState editor;
  final ProjectScreen? rename;

  const _ScreenDialog({required this.editor, this.rename});

  @override
  State<_ScreenDialog> createState() => _ScreenDialogState();
}

class _ScreenDialogState extends State<_ScreenDialog> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.rename?.name ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    if (widget.rename != null) {
      widget.editor.renameScreen(widget.rename!.id, name);
    } else {
      widget.editor.addScreen(name);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        widget.rename == null ? l10n.addScreen : l10n.renameScreen,
      ),
      content: TextField(
        key: const Key('screen.name'),
        controller: _name,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.screenName,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('screen.confirm'),
          onPressed: _submit,
          child: Text(l10n.create),
        ),
      ],
    );
  }
}

class _Canvas extends StatelessWidget {
  final EditorState editor;

  const _Canvas({required this.editor});

  @override
  Widget build(BuildContext context) {
    final project = editor.project;
    final size = ProjectPage.deviceSizes[editor.device]!;
    final dark = switch (project.theme.brightness) {
      ThemeBrightness.system => editor.previewDark,
      ThemeBrightness.light => false,
      ThemeBrightness.dark => true,
    };
    final scheme = ColorScheme.fromSeed(
      seedColor: Color(project.theme.seedColor),
      brightness: dark ? Brightness.dark : Brightness.light,
    );
    return Center(
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 24,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: scheme,
            useMaterial3: true,
            fontFamily: 'Inter',
          ),
          home: NodePreview(
            project: project,
            screen: editor.screen,
            selectedId: editor.selectedId,
            responsive: editor.screen.responsive,
            onSelect: editor.select,
          ),
        ),
      ),
    );
  }
}
