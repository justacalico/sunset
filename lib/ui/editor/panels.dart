import 'package:flutter/material.dart';

import '../../core/model.dart';
import '../../l10n/app_localizations.dart';
import '../../state/editor_state.dart';
import 'inspector.dart' show swatchColors;

class ThemePanel extends StatelessWidget {
  final EditorState editor;

  const ThemePanel({super.key, required this.editor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final theme = editor.project.theme;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          l10n.seedColor,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final color in swatchColors.skip(1))
              InkWell(
                key: Key('theme.seed.${color.toRadixString(16)}'),
                onTap: () => editor.setSeedColor(color),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(color),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.seedColor == color
                          ? scheme.primary
                          : scheme.outlineVariant,
                      width: theme.seedColor == color ? 3 : 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.brightness,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        SegmentedButton<ThemeBrightness>(
          key: const Key('theme.brightness'),
          segments: [
            ButtonSegment(
              value: ThemeBrightness.system,
              label: Text(l10n.themeSystem),
            ),
            ButtonSegment(
              value: ThemeBrightness.light,
              label: Text(l10n.themeLight),
            ),
            ButtonSegment(
              value: ThemeBrightness.dark,
              label: Text(l10n.themeDark),
            ),
          ],
          selected: {theme.brightness},
          onSelectionChanged: (v) => editor.setBrightness(v.first),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          key: const Key('theme.responsive'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.responsive, style: const TextStyle(fontSize: 13)),
          subtitle: Text(
            l10n.responsiveHint,
            style: const TextStyle(fontSize: 11),
          ),
          value: editor.screen.responsive,
          onChanged: editor.setResponsive,
        ),
        const SizedBox(height: 8),
        _PackageField(editor: editor),
      ],
    );
  }
}

class _PackageField extends StatefulWidget {
  final EditorState editor;

  const _PackageField({required this.editor});

  @override
  State<_PackageField> createState() => _PackageFieldState();
}

class _PackageFieldState extends State<_PackageField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.editor.project.packageName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      key: const Key('theme.package'),
      controller: _controller,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        isDense: true,
        border: const OutlineInputBorder(),
        labelText: l10n.packageName,
      ),
      onSubmitted: widget.editor.setPackageName,
      onTapOutside: (_) => widget.editor.setPackageName(_controller.text),
    );
  }
}

class StringsPanel extends StatelessWidget {
  final EditorState editor;

  const StringsPanel({super.key, required this.editor});

  static const localeChoices = {
    'en_GB': 'Traditional English',
    'zh_Hans': '简体中文',
    'ru': 'Русский',
    'ga': 'Gaeilge',
    'fr': 'Français',
    'de': 'Deutsch',
    'es': 'Español',
    'ja': '日本語',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final project = editor.project;
    final keys = project.messages.keys.toList()..sort();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.locales,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ),
            IconButton(
              key: const Key('strings.addLocale'),
              icon: const Icon(Icons.add, size: 18),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => _LocaleDialog(editor: editor),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final tag in project.locales)
              InputChip(
                key: Key('strings.locale.$tag'),
                deleteIcon: const Icon(Icons.close, size: 16),
                label: Text(localeChoices[tag] ?? tag),
                onDeleted: project.locales.length > 1
                    ? () => editor.removeLocale(tag)
                    : null,
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.stringsTitle,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ),
            IconButton(
              key: const Key('strings.addKey'),
              icon: const Icon(Icons.add, size: 18),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => _KeyDialog(editor: editor),
              ),
            ),
          ],
        ),
        for (final key in keys)
          Card(
            key: Key('strings.key.$key'),
            margin: const EdgeInsets.symmetric(vertical: 3),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      InkWell(
                        key: Key('strings.delete.$key'),
                        onTap: () => editor.removeMessage(key),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  for (final tag in project.locales)
                    _MessageField(
                      key: Key('strings.field.$key.$tag'),
                      editor: editor,
                      messageKey: key,
                      locale: tag,
                      initial: project.messages[key]?[tag] ?? '',
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MessageField extends StatefulWidget {
  final EditorState editor;
  final String messageKey;
  final String locale;
  final String initial;

  const _MessageField({
    required this.editor,
    required this.messageKey,
    required this.locale,
    required this.initial,
    super.key,
  });

  @override
  State<_MessageField> createState() => _MessageFieldState();
}

class _MessageFieldState extends State<_MessageField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: TextField(
        controller: _controller,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: widget.locale,
        ),
        onSubmitted: (v) =>
            widget.editor.setMessage(widget.messageKey, widget.locale, v),
        onTapOutside: (_) => widget.editor.setMessage(
          widget.messageKey,
          widget.locale,
          _controller.text,
        ),
      ),
    );
  }
}

class _LocaleDialog extends StatelessWidget {
  final EditorState editor;

  const _LocaleDialog({required this.editor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final remaining = StringsPanel.localeChoices.entries
        .where((e) => !editor.project.locales.contains(e.key))
        .toList();
    return SimpleDialog(
      title: Text(l10n.addLocale),
      children: [
        for (final e in remaining)
          SimpleDialogOption(
            key: Key('locale.pick.${e.key}'),
            onPressed: () {
              editor.addLocale(e.key);
              Navigator.of(context).pop();
            },
            child: Text(e.value),
          ),
      ],
    );
  }
}

class _KeyDialog extends StatefulWidget {
  final EditorState editor;

  const _KeyDialog({required this.editor});

  @override
  State<_KeyDialog> createState() => _KeyDialogState();
}

class _KeyDialogState extends State<_KeyDialog> {
  final _key = TextEditingController();

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  void _add() {
    final key = _key.text.trim();
    if (key.isEmpty) return;
    widget.editor.setMessage(
      key,
      widget.editor.baseLocale,
      '',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.addString),
      content: TextField(
        key: const Key('strings.keyName'),
        controller: _key,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.stringKey,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _add(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('strings.keyConfirm'),
          onPressed: _add,
          child: Text(l10n.create),
        ),
      ],
    );
  }
}

class GitPanel extends StatelessWidget {
  final EditorState editor;

  const GitPanel({super.key, required this.editor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (!editor.gitRepo && !editor.gitBusy && editor.gitError == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.gitNotRepo),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('git.init'),
              onPressed: editor.gitInit,
              icon: const Icon(Icons.source_outlined),
              label: Text(l10n.gitInit),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (editor.gitBusy)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        if (editor.gitError != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              editor.gitError!,
              style: TextStyle(color: scheme.error, fontSize: 12),
            ),
          ),
        if (editor.gitRepo) ...[
          Row(
            children: [
              Icon(Icons.call_split, size: 16, color: scheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  editor.gitBranch.isEmpty ? 'main' : editor.gitBranch,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              IconButton(
                key: const Key('git.refresh'),
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: editor.gitRefresh,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _CommitBox(editor: editor),
          const SizedBox(height: 12),
          Text(
            l10n.gitChanges,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          if (editor.gitFiles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.gitClean, style: const TextStyle(fontSize: 12)),
            )
          else
            for (final f in editor.gitFiles.take(30))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        f.status,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.primary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        f.path,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 12),
          Text(
            l10n.gitHistory,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          for (final c in editor.gitLog.take(15))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Text(
                    c.hash,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.tertiary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.subject,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _CommitBox extends StatefulWidget {
  final EditorState editor;

  const _CommitBox({required this.editor});

  @override
  State<_CommitBox> createState() => _CommitBoxState();
}

class _CommitBoxState extends State<_CommitBox> {
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('git.message'),
            controller: _message,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              hintText: l10n.commitMessage,
            ),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                widget.editor.gitCommit(v.trim());
                _message.clear();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          key: const Key('git.commit'),
          icon: const Icon(Icons.check, size: 18),
          onPressed: () {
            if (_message.text.trim().isNotEmpty) {
              widget.editor.gitCommit(_message.text.trim());
              _message.clear();
            }
          },
        ),
      ],
    );
  }
}

class ExportPanel extends StatelessWidget {
  final EditorState editor;

  const ExportPanel({super.key, required this.editor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final project = editor.project;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          l10n.exportInfo,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        if (project.imported)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.exportImportedHint,
              style: TextStyle(fontSize: 12, color: scheme.tertiary),
            ),
          ),
        FilledButton.icon(
          key: const Key('export.run'),
          onPressed: () async {
            final count = await editor.export();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.exportedFiles(count))),
              );
            }
          },
          icon: const Icon(Icons.file_download_outlined),
          label: Text(l10n.exportButton),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.exportTargets,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        for (final f in [
          'pubspec.yaml',
          'lib/main.dart',
          'lib/sunset_l10n.dart',
          for (final s in project.screens)
            'lib/screens/${s.name.toLowerCase().replaceAll(' ', '_')}.dart',
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Text(
              f,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
      ],
    );
  }
}
