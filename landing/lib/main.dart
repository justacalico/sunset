import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'page.dart';

enum LandingTheme { system, light, dark, oled }

class LandingScope extends InheritedNotifier<LandingState> {
  const LandingScope({super.key, required LandingState s, required super.child})
    : super(notifier: s);

  static LandingState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LandingScope>()!.notifier!;
}

class LandingState extends ChangeNotifier {
  LandingTheme theme = LandingTheme.system;
  Locale? locale;
  SharedPreferences? prefs;

  Future<void> load() async {
    prefs = await SharedPreferences.getInstance();
    theme = LandingTheme.values.firstWhere(
      (t) => t.name == (prefs!.getString('landing_theme') ?? ''),
      orElse: () => LandingTheme.system,
    );
    final tag = prefs!.getString('landing_locale') ?? '';
    if (tag.isNotEmpty) locale = _parse(tag);
    notifyListeners();
  }

  void setTheme(LandingTheme t) {
    theme = t;
    prefs?.setString('landing_theme', t.name);
    notifyListeners();
  }

  void setLocale(Locale? l) {
    locale = l;
    if (l == null) {
      prefs?.remove('landing_locale');
    } else {
      prefs?.setString('landing_locale', _tag(l));
    }
    notifyListeners();
  }

  static String _tag(Locale l) => l.countryCode == null
      ? l.languageCode
      : '${l.languageCode}_${l.countryCode}';

  static Locale _parse(String tag) {
    final parts = tag.split('_');
    return parts.length > 1
        ? Locale.fromSubtags(
            languageCode: parts[0],
            scriptCode: parts[0] == 'zh' ? 'Hans' : null,
            countryCode: parts[0] == 'zh' ? null : parts[1],
          )
        : Locale(parts[0]);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final s = LandingState();
  await s.load();
  runApp(LandingApp(state: s));
}

class LandingApp extends StatelessWidget {
  final LandingState state;

  const LandingApp({super.key, required this.state});

  static const seed = Color(0xFFF3813F);

  ThemeData _light() => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    ),
    fontFamily: 'Inter',
    useMaterial3: true,
  );

  ThemeData _dark({bool oled = false}) {
    var d = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Inter',
      useMaterial3: true,
    );
    if (oled) {
      d = d.copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: d.colorScheme.copyWith(
          surface: Colors.black,
          surfaceContainer: const Color(0xFF0D0D0D),
          surfaceContainerHighest: const Color(0xFF161616),
        ),
      );
    }
    return d;
  }

  @override
  Widget build(BuildContext context) {
    return LandingScope(
      s: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final oled = state.theme == LandingTheme.oled;
          return MaterialApp(
            onGenerateTitle: (c) => 'Sunset',
            debugShowCheckedModeBanner: false,
            theme: _light(),
            darkTheme: _dark(oled: oled),
            themeMode: switch (state.theme) {
              LandingTheme.system => ThemeMode.system,
              LandingTheme.light => ThemeMode.light,
              LandingTheme.dark || LandingTheme.oled => ThemeMode.dark,
            },
            locale: state.locale,
            localizationsDelegates: const [
              LandingLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LandingLocalizations.supportedLocales,
            home: LandingPage(
              theme: state.theme,
              locale: state.locale,
              onTheme: state.setTheme,
              onLocale: state.setLocale,
            ),
          );
        },
      ),
    );
  }
}
