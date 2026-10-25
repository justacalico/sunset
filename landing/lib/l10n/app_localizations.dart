import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ga.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of LandingLocalizations
/// returned by `LandingLocalizations.of(context)`.
///
/// Applications need to include `LandingLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: LandingLocalizations.localizationsDelegates,
///   supportedLocales: LandingLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the LandingLocalizations.supportedLocales
/// property.
abstract class LandingLocalizations {
  LandingLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static LandingLocalizations of(BuildContext context) {
    return Localizations.of<LandingLocalizations>(
      context,
      LandingLocalizations,
    )!;
  }

  static const LocalizationsDelegate<LandingLocalizations> delegate =
      _LandingLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'GB'),
    Locale('ga'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en_GB, this message translates to:
  /// **'Sunset'**
  String get appTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en_GB, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en_GB, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en_GB, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeOled.
  ///
  /// In en_GB, this message translates to:
  /// **'OLED'**
  String get themeOled;

  /// No description provided for @languageSystem.
  ///
  /// In en_GB, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @tagline.
  ///
  /// In en_GB, this message translates to:
  /// **'Visual Flutter builder'**
  String get tagline;

  /// No description provided for @hero.
  ///
  /// In en_GB, this message translates to:
  /// **'Design Flutter apps without writing code'**
  String get hero;

  /// No description provided for @sub.
  ///
  /// In en_GB, this message translates to:
  /// **'Place widgets on a canvas, style everything, manage locales and git, then export a real Flutter project. A full CLI gives agents the same powers.'**
  String get sub;

  /// No description provided for @openApp.
  ///
  /// In en_GB, this message translates to:
  /// **'Open the app'**
  String get openApp;

  /// No description provided for @getDownloads.
  ///
  /// In en_GB, this message translates to:
  /// **'Downloads'**
  String get getDownloads;

  /// No description provided for @sourceLink.
  ///
  /// In en_GB, this message translates to:
  /// **'Source'**
  String get sourceLink;

  /// No description provided for @featuresTitle.
  ///
  /// In en_GB, this message translates to:
  /// **'Why Sunset'**
  String get featuresTitle;

  /// No description provided for @feature1Title.
  ///
  /// In en_GB, this message translates to:
  /// **'Everything on a canvas'**
  String get feature1Title;

  /// No description provided for @feature1Body.
  ///
  /// In en_GB, this message translates to:
  /// **'Drop widgets into a live preview, tweak props in the inspector, and watch the real Flutter widgets update as you work.'**
  String get feature1Body;

  /// No description provided for @feature2Title.
  ///
  /// In en_GB, this message translates to:
  /// **'Real Flutter output'**
  String get feature2Title;

  /// No description provided for @feature2Body.
  ///
  /// In en_GB, this message translates to:
  /// **'Export generates clean Dart: screens, theme and localization files you can keep editing by hand whenever you want.'**
  String get feature2Body;

  /// No description provided for @feature3Title.
  ///
  /// In en_GB, this message translates to:
  /// **'Built-in i18n and git'**
  String get feature3Title;

  /// No description provided for @feature3Body.
  ///
  /// In en_GB, this message translates to:
  /// **'Manage locales and strings in one panel, bind text to keys, and commit your work without leaving the app.'**
  String get feature3Body;

  /// No description provided for @feature4Title.
  ///
  /// In en_GB, this message translates to:
  /// **'CLI with full parity'**
  String get feature4Title;

  /// No description provided for @feature4Body.
  ///
  /// In en_GB, this message translates to:
  /// **'Every editor action exists in the sunset CLI, so scripts and AI agents can build the same projects headlessly.'**
  String get feature4Body;

  /// No description provided for @downloadsTitle.
  ///
  /// In en_GB, this message translates to:
  /// **'Downloads'**
  String get downloadsTitle;

  /// No description provided for @downloadsSub.
  ///
  /// In en_GB, this message translates to:
  /// **'Stable releases for every desktop platform, straight from GitLab Releases.'**
  String get downloadsSub;

  /// No description provided for @flatpakHint.
  ///
  /// In en_GB, this message translates to:
  /// **'Flatpak one-liner:'**
  String get flatpakHint;

  /// No description provided for @loadingReleases.
  ///
  /// In en_GB, this message translates to:
  /// **'Loading releases…'**
  String get loadingReleases;

  /// No description provided for @releasesError.
  ///
  /// In en_GB, this message translates to:
  /// **'Could not load releases'**
  String get releasesError;

  /// No description provided for @noReleases.
  ///
  /// In en_GB, this message translates to:
  /// **'No releases yet'**
  String get noReleases;

  /// No description provided for @gitlabReleases.
  ///
  /// In en_GB, this message translates to:
  /// **'All releases on GitLab'**
  String get gitlabReleases;

  /// No description provided for @screensTitle.
  ///
  /// In en_GB, this message translates to:
  /// **'Inside the builder'**
  String get screensTitle;
}

class _LandingLocalizationsDelegate
    extends LocalizationsDelegate<LandingLocalizations> {
  const _LandingLocalizationsDelegate();

  @override
  Future<LandingLocalizations> load(Locale locale) {
    return SynchronousFuture<LandingLocalizations>(
      lookupLandingLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ga', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_LandingLocalizationsDelegate old) => false;
}

LandingLocalizations lookupLandingLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return LandingLocalizationsZhHans();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return LandingLocalizationsEnGb();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return LandingLocalizationsEn();
    case 'ga':
      return LandingLocalizationsGa();
    case 'ru':
      return LandingLocalizationsRu();
    case 'zh':
      return LandingLocalizationsZh();
  }

  throw FlutterError(
    'LandingLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
