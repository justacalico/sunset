import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'l10n/app_localizations.dart';
import 'main.dart';
import 'releases.dart';
import 'showcase.dart';

class LandingPage extends StatelessWidget {
  final LandingTheme theme;
  final Locale? locale;
  final ValueChanged<LandingTheme> onTheme;
  final ValueChanged<Locale?> onLocale;
  final Future<List<Release>> Function()? releasesLoader;

  const LandingPage({
    super.key,
    required this.theme,
    required this.locale,
    required this.onTheme,
    required this.onLocale,
    this.releasesLoader,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = LandingLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width > 900;
    final scrollKey = GlobalKey();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Row(
            children: [
              const Icon(Icons.wb_twilight),
              const SizedBox(width: 8),
              const Text(
                'Sunset',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              DropdownButton<LandingTheme>(
                key: const Key('theme'),
                value: theme,
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(
                    value: LandingTheme.system,
                    child: Text(l10n.themeSystem),
                  ),
                  DropdownMenuItem(
                    value: LandingTheme.light,
                    child: Text(l10n.themeLight),
                  ),
                  DropdownMenuItem(
                    value: LandingTheme.dark,
                    child: Text(l10n.themeDark),
                  ),
                  DropdownMenuItem(
                    value: LandingTheme.oled,
                    child: Text(l10n.themeOled),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) onTheme(v);
                },
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                key: const Key('language'),
                value: _localeTag(locale),
                underline: const SizedBox.shrink(),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text(l10n.languageSystem),
                  ),
                  const DropdownMenuItem(
                    value: 'en_GB',
                    child: Text('Traditional English'),
                  ),
                  const DropdownMenuItem(
                    value: 'zh_Hans',
                    child: Text('简体中文'),
                  ),
                  const DropdownMenuItem(value: 'ru', child: Text('Русский')),
                  const DropdownMenuItem(value: 'ga', child: Text('Gaeilge')),
                ],
                onChanged: (v) => onLocale(_parseLocale(v)),
              ),
            ],
          ),
          const SizedBox(height: 48),
          _Hero(wide: wide, scrollKey: scrollKey),
          const SizedBox(height: 56),
          Center(
            child: Text(
              l10n.featuresTitle,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _feature(
                context,
                Icons.widgets_outlined,
                l10n.feature1Title,
                l10n.feature1Body,
              ),
              _feature(
                context,
                Icons.code,
                l10n.feature2Title,
                l10n.feature2Body,
              ),
              _feature(
                context,
                Icons.translate,
                l10n.feature3Title,
                l10n.feature3Body,
              ),
              _feature(
                context,
                Icons.terminal,
                l10n.feature4Title,
                l10n.feature4Body,
              ),
            ],
          ),
          const SizedBox(height: 56),
          Center(
            child: Text(
              l10n.screensTitle,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/screenshots/editor.png',
                    width: 620,
                    fit: BoxFit.cover,
                    errorBuilder: (context, e, s) => const EditorMock(),
                  ),
                ),
                const SizedBox(width: 300, height: 300, child: SunsetScene()),
              ],
            ),
          ),
          const SizedBox(height: 56),
          Container(key: scrollKey),
          Center(
            child: Text(
              l10n.downloadsTitle,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n.downloadsSub,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 20),
          _ReleasesList(loader: releasesLoader ?? fetchReleases),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '${l10n.flatpakHint} flatpak install https://httpanimations.gitlab.io/sunset/sunset.flatpakref',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  static String _localeTag(Locale? locale) {
    if (locale == null) return '';
    return locale.countryCode == null
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
  }

  static Locale? _parseLocale(String? tag) {
    if (tag == null || tag.isEmpty) return null;
    final parts = tag.split('_');
    return parts.length > 1
        ? Locale.fromSubtags(
            languageCode: parts[0],
            scriptCode: parts[0] == 'zh' ? 'Hans' : null,
            countryCode: parts[0] == 'zh' ? null : parts[1],
          )
        : Locale(parts[0]);
  }

  Widget _feature(
    BuildContext context,
    IconData icon,
    String title,
    String body,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body, style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final bool wide;
  final GlobalKey scrollKey;

  const _Hero({required this.wide, required this.scrollKey});

  Future<void> _open(String url) => launchUrl(Uri.parse(url));

  @override
  Widget build(BuildContext context) {
    final l10n = LandingLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: wide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          l10n.tagline,
          style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.hero,
          textAlign: wide ? TextAlign.left : TextAlign.center,
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.sub,
          textAlign: wide ? TextAlign.left : TextAlign.center,
          style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: wide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            FilledButton.icon(
              key: const Key('openApp'),
              onPressed: () => _open('app/'),
              icon: const Icon(Icons.wb_twilight),
              label: Text(l10n.openApp),
            ),
            OutlinedButton.icon(
              key: const Key('downloads'),
              onPressed: () => Scrollable.ensureVisible(
                scrollKey.currentContext!,
                duration: const Duration(milliseconds: 300),
              ),
              icon: const Icon(Icons.download_outlined),
              label: Text(l10n.getDownloads),
            ),
            TextButton.icon(
              key: const Key('source'),
              onPressed: () =>
                  _open('https://gitlab.com/HttpAnimations/sunset'),
              icon: const Icon(Icons.code),
              label: Text(l10n.sourceLink),
            ),
          ],
        ),
      ],
    );
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: text),
          const SizedBox(width: 32),
          const EditorMock(),
        ],
      );
    }
    return Column(
      children: [text, const SizedBox(height: 32), const EditorMock()],
    );
  }
}

class _ReleasesList extends StatelessWidget {
  final Future<List<Release>> Function() loader;

  const _ReleasesList({required this.loader});

  Future<void> _open(String url) => launchUrl(Uri.parse(url));

  @override
  Widget build(BuildContext context) {
    final l10n = LandingLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<Release>>(
      future: loader(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Center(child: Text(l10n.loadingReleases));
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              children: [
                Text(l10n.releasesError),
                TextButton.icon(
                  onPressed: () => _open(
                    'https://gitlab.com/HttpAnimations/sunset/-/releases',
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.gitlabReleases),
                ),
              ],
            ),
          );
        }
        final releases = snap.data ?? const [];
        if (releases.isEmpty) {
          return Center(
            child: Column(
              children: [
                Text(l10n.noReleases),
                TextButton.icon(
                  onPressed: () => _open(
                    'https://gitlab.com/HttpAnimations/sunset/-/releases',
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.gitlabReleases),
                ),
              ],
            ),
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                for (final r in releases.take(3))
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name.isEmpty ? r.tag : r.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            r.releasedAt.split('T').first,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final a in r.assets)
                                ActionChip(
                                  avatar: const Icon(
                                    Icons.download_outlined,
                                    size: 16,
                                  ),
                                  label: Text(a.name),
                                  onPressed: () => _open(a.url),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => _open(
                    'https://gitlab.com/HttpAnimations/sunset/-/releases',
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.gitlabReleases),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
