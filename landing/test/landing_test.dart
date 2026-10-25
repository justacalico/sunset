import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunset_landing/l10n/app_localizations.dart';
import 'package:sunset_landing/main.dart';
import 'package:sunset_landing/page.dart';
import 'package:sunset_landing/releases.dart';
import 'package:sunset_landing/showcase.dart';

Widget _page({LandingTheme theme = LandingTheme.system, Locale? locale, Future<List<Release>> Function()? loader}) {
  return MaterialApp(
    supportedLocales: LandingLocalizations.supportedLocales,
    localizationsDelegates: const [
      LandingLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: LandingPage(
      theme: theme,
      locale: locale,
      onTheme: (_) {},
      onLocale: (_) {},
      releasesLoader: loader,
    ),
  );
}

void main() {
  test('fetchReleases parses and fails cleanly', () async {
    final client = MockClient((req) async => http.Response(
        '[{"tag_name":"v1.0.0","name":"Sunset v1.0.0","released_at":"2026-01-01T00:00:00Z","assets":{"links":[{"name":"apk","url":"https://x/apk"}]}}]',
        200));
    final releases = await fetchReleases(client: client);
    expect(releases.single.tag, 'v1.0.0');
    expect(releases.single.assets.single.name, 'apk');
    final bad = MockClient((req) async => http.Response('x', 500));
    expect(() => fetchReleases(client: bad), throwsException);
    final odd = MockClient((req) async => http.Response('{"a":1}', 200));
    expect(await fetchReleases(client: odd), isEmpty);
  });

  test('LandingState persists theme and locale', () async {
    SharedPreferences.setMockInitialValues({});
    final s = LandingState();
    await s.load();
    expect(s.theme, LandingTheme.system);
    s.setTheme(LandingTheme.oled);
    s.setLocale(const Locale('ru'));
    expect(s.theme, LandingTheme.oled);
    expect(s.prefs!.getString('landing_locale'), 'ru');
    s.setLocale(null);
    expect(s.prefs!.getString('landing_locale'), isNull);
    final s2 = LandingState();
    SharedPreferences.setMockInitialValues({'landing_theme': 'dark', 'landing_locale': 'zh_Hans'});
    await s2.load();
    expect(s2.theme, LandingTheme.dark);
    expect(s2.locale, const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'));
  });

  testWidgets('landing renders, picks theme and locale', (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    var theme = LandingTheme.system;
    Locale? picked;
    await tester.pumpWidget(MaterialApp(
      supportedLocales: LandingLocalizations.supportedLocales,
      localizationsDelegates: const [
        LandingLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: LandingPage(
        theme: theme,
        locale: null,
        onTheme: (t) => theme = t,
        onLocale: (l) => picked = l,
        releasesLoader: () async => const [],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Sunset'), findsWidgets);
    expect(find.byType(EditorMock), findsWidgets);
    await tester.tap(find.byKey(const Key('theme')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OLED').last);
    await tester.pumpAndSettle();
    expect(theme, LandingTheme.oled);
    await tester.tap(find.byKey(const Key('language')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('简体中文').last);
    await tester.pumpAndSettle();
    expect(picked, const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'));
    await tester.tap(find.byKey(const Key('downloads')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openApp')));
    await tester.pump();
  });

  testWidgets('releases list states', (tester) async {
    tester.view.physicalSize = const Size(900, 2800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_page(loader: () async => [
      const Release('v1', 'v1', '2026-01-01', [(name: 'apk', url: 'https://x')]),
    ]));
    await tester.pumpAndSettle();
    expect(find.text('v1'), findsOneWidget);
    await tester.pumpWidget(_page(loader: () async => throw Exception('x')));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_page(loader: () async => const []));
    await tester.pumpAndSettle();
  });

  testWidgets('narrow layout and app shell', (tester) async {
    tester.view.physicalSize = const Size(700, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final s = LandingState();
    await s.load();
    await tester.pumpWidget(LandingApp(state: s));
    await tester.pumpAndSettle();
    expect(find.text('Sunset'), findsWidgets);
    expect(find.byType(EditorMock), findsWidgets);
  });

  testWidgets('SunsetScene paints', (tester) async {
    await tester.pumpWidget(const SizedBox(
      width: 300,
      height: 300,
      child: SunsetScene(),
    ));
    expect(find.byType(SunsetScene), findsOneWidget);
  });
}
