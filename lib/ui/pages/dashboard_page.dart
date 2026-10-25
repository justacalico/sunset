import 'package:flutter/material.dart';

import '../../core/importer.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../state/project_registry.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<void> _newProject(BuildContext context, AppState state) async {
    final l10n = AppLocalizations.of(context);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _NewProjectDialog(),
    );
    if (name == null || name.isEmpty || !context.mounted) return;
    final dir = await state.pickDir?.call();
    if (dir == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.noDirectoryPicked)));
      }
      return;
    }
    if (!context.mounted) return;
    try {
      await state.createProject('$dir/${_slug(name)}', name);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  static String _slug(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  Future<void> _importProject(BuildContext context, AppState state) async {
    final l10n = AppLocalizations.of(context);
    final dir = await state.pickDir?.call();
    if (dir == null || !context.mounted) return;
    try {
      await state.importProject(dir);
    } on ImportException {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.notFlutterProject)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: state.registry,
      builder: (context, _) {
        final entries = state.registry.entries;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  key: const Key('dashboard.new'),
                  onPressed: () => _newProject(context, state),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.newProject),
                ),
                FilledButton.tonalIcon(
                  key: const Key('dashboard.import'),
                  onPressed: state.pickDir == null
                      ? null
                      : () => _importProject(context, state),
                  icon: const Icon(Icons.file_open_outlined),
                  label: Text(l10n.importProject),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Column(
                  children: [
                    Icon(
                      Icons.widgets_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.emptyProjects,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final entry in entries)
                    _ProjectCard(entry: entry, state: state),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectEntry entry;
  final AppState state;

  const _ProjectCard({required this.entry, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 260,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('project.${entry.name}'),
          onTap: () => state.openProject(entry.path),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      entry.imported
                          ? Icons.folder_open_outlined
                          : Icons.widgets_outlined,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      key: Key('remove.${entry.name}'),
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: l10n.removeFromList,
                      onPressed: () =>
                          state.registry.remove(entry.path, state.prefs),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  entry.path,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (entry.imported)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l10n.importedBadge,
                      style: TextStyle(fontSize: 11, color: scheme.tertiary),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewProjectDialog extends StatefulWidget {
  const _NewProjectDialog();

  @override
  State<_NewProjectDialog> createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends State<_NewProjectDialog> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.newProject),
      content: TextField(
        key: const Key('dashboard.projectName'),
        controller: _name,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.projectName,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const Key('dashboard.createConfirm'),
          onPressed: () => Navigator.of(context).pop(_name.text.trim()),
          child: Text(l10n.create),
        ),
      ],
    );
  }
}
