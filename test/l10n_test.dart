import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunset/app.dart';
import 'package:sunset/l10n/app_localizations.dart';
import 'package:sunset/state/app_state.dart';
import 'package:sunset/state/settings_store.dart';

import 'fakes.dart';

void main() {
  for (final locale in supportedLocales) {
    testWidgets('renders in ${locale.toLanguageTag()}', (tester) async {
      final state = await testState();
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await state.settings.setLocale(locale, state.prefs);
      await tester.pumpWidget(AppScope(state: state, child: const SunsetApp()));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      state.selectTab(1);
      await tester.pumpAndSettle();
      state.selectTab(0);
      await tester.pumpAndSettle();
    });
  }

  test('all supported locales have translations', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      expect(l10n.appTitle, isNotEmpty, reason: '$locale');
      expect(l10n.navDashboard, isNotEmpty);
      expect(l10n.checkUpdates, isNotEmpty);
      expect(l10n.panelWidgets, isNotEmpty);
    }
  });
}
