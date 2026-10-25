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

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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

  /// No description provided for @navDashboard.
  ///
  /// In en_GB, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navSettings.
  ///
  /// In en_GB, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @appearanceSection.
  ///
  /// In en_GB, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// No description provided for @aboutSection.
  ///
  /// In en_GB, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @theme.
  ///
  /// In en_GB, this message translates to:
  /// **'Theme'**
  String get theme;

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

  /// No description provided for @accentColor.
  ///
  /// In en_GB, this message translates to:
  /// **'Accent colour'**
  String get accentColor;

  /// No description provided for @language.
  ///
  /// In en_GB, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en_GB, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @versionLabel.
  ///
  /// In en_GB, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @checkUpdates.
  ///
  /// In en_GB, this message translates to:
  /// **'Check for updates'**
  String get checkUpdates;

  /// No description provided for @updateChecking.
  ///
  /// In en_GB, this message translates to:
  /// **'Checking…'**
  String get updateChecking;

  /// No description provided for @updateFailed.
  ///
  /// In en_GB, this message translates to:
  /// **'Check failed'**
  String get updateFailed;

  /// No description provided for @updateAvailable.
  ///
  /// In en_GB, this message translates to:
  /// **'Version {version} is available'**
  String updateAvailable(String version);

  /// No description provided for @upToDate.
  ///
  /// In en_GB, this message translates to:
  /// **'Up to date'**
  String get upToDate;

  /// No description provided for @getUpdate.
  ///
  /// In en_GB, this message translates to:
  /// **'Get {version}'**
  String getUpdate(String version);

  /// No description provided for @releasesLink.
  ///
  /// In en_GB, this message translates to:
  /// **'All releases'**
  String get releasesLink;

  /// No description provided for @sourceLink.
  ///
  /// In en_GB, this message translates to:
  /// **'Source code'**
  String get sourceLink;

  /// No description provided for @newProject.
  ///
  /// In en_GB, this message translates to:
  /// **'New project'**
  String get newProject;

  /// No description provided for @importProject.
  ///
  /// In en_GB, this message translates to:
  /// **'Import Flutter project'**
  String get importProject;

  /// No description provided for @emptyProjects.
  ///
  /// In en_GB, this message translates to:
  /// **'No projects yet. Create one or import an existing Flutter project.'**
  String get emptyProjects;

  /// No description provided for @projectName.
  ///
  /// In en_GB, this message translates to:
  /// **'Project name'**
  String get projectName;

  /// No description provided for @cancel.
  ///
  /// In en_GB, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en_GB, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @removeFromList.
  ///
  /// In en_GB, this message translates to:
  /// **'Remove from list'**
  String get removeFromList;

  /// No description provided for @importedBadge.
  ///
  /// In en_GB, this message translates to:
  /// **'Imported'**
  String get importedBadge;

  /// No description provided for @noDirectoryPicked.
  ///
  /// In en_GB, this message translates to:
  /// **'No folder picked'**
  String get noDirectoryPicked;

  /// No description provided for @notFlutterProject.
  ///
  /// In en_GB, this message translates to:
  /// **'That folder is not a Flutter project'**
  String get notFlutterProject;

  /// No description provided for @backToDashboard.
  ///
  /// In en_GB, this message translates to:
  /// **'Back to dashboard'**
  String get backToDashboard;

  /// No description provided for @addScreen.
  ///
  /// In en_GB, this message translates to:
  /// **'Add screen'**
  String get addScreen;

  /// No description provided for @renameScreen.
  ///
  /// In en_GB, this message translates to:
  /// **'Rename screen'**
  String get renameScreen;

  /// No description provided for @screenName.
  ///
  /// In en_GB, this message translates to:
  /// **'Screen name'**
  String get screenName;

  /// No description provided for @saveProject.
  ///
  /// In en_GB, this message translates to:
  /// **'Save project'**
  String get saveProject;

  /// No description provided for @projectSaved.
  ///
  /// In en_GB, this message translates to:
  /// **'Project saved'**
  String get projectSaved;

  /// No description provided for @panelWidgets.
  ///
  /// In en_GB, this message translates to:
  /// **'Widgets'**
  String get panelWidgets;

  /// No description provided for @panelTree.
  ///
  /// In en_GB, this message translates to:
  /// **'Tree'**
  String get panelTree;

  /// No description provided for @panelProps.
  ///
  /// In en_GB, this message translates to:
  /// **'Props'**
  String get panelProps;

  /// No description provided for @panelTheme.
  ///
  /// In en_GB, this message translates to:
  /// **'Theme'**
  String get panelTheme;

  /// No description provided for @panelStrings.
  ///
  /// In en_GB, this message translates to:
  /// **'Strings'**
  String get panelStrings;

  /// No description provided for @panelGit.
  ///
  /// In en_GB, this message translates to:
  /// **'Git'**
  String get panelGit;

  /// No description provided for @panelExport.
  ///
  /// In en_GB, this message translates to:
  /// **'Export'**
  String get panelExport;

  /// No description provided for @groupLayout.
  ///
  /// In en_GB, this message translates to:
  /// **'Layout'**
  String get groupLayout;

  /// No description provided for @groupContent.
  ///
  /// In en_GB, this message translates to:
  /// **'Content'**
  String get groupContent;

  /// No description provided for @inspectorEmpty.
  ///
  /// In en_GB, this message translates to:
  /// **'Select a widget on the canvas or in the tree to edit it.'**
  String get inspectorEmpty;

  /// No description provided for @unknownWidget.
  ///
  /// In en_GB, this message translates to:
  /// **'Unknown widget type'**
  String get unknownWidget;

  /// No description provided for @noneOption.
  ///
  /// In en_GB, this message translates to:
  /// **'None'**
  String get noneOption;

  /// No description provided for @seedColor.
  ///
  /// In en_GB, this message translates to:
  /// **'Seed colour'**
  String get seedColor;

  /// No description provided for @brightness.
  ///
  /// In en_GB, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @responsive.
  ///
  /// In en_GB, this message translates to:
  /// **'Responsive layout'**
  String get responsive;

  /// No description provided for @responsiveHint.
  ///
  /// In en_GB, this message translates to:
  /// **'Generated screens adapt their padding to the window width.'**
  String get responsiveHint;

  /// No description provided for @packageName.
  ///
  /// In en_GB, this message translates to:
  /// **'Package name'**
  String get packageName;

  /// No description provided for @locales.
  ///
  /// In en_GB, this message translates to:
  /// **'Locales'**
  String get locales;

  /// No description provided for @addLocale.
  ///
  /// In en_GB, this message translates to:
  /// **'Add locale'**
  String get addLocale;

  /// No description provided for @stringsTitle.
  ///
  /// In en_GB, this message translates to:
  /// **'Strings'**
  String get stringsTitle;

  /// No description provided for @addString.
  ///
  /// In en_GB, this message translates to:
  /// **'Add string'**
  String get addString;

  /// No description provided for @stringKey.
  ///
  /// In en_GB, this message translates to:
  /// **'Key'**
  String get stringKey;

  /// No description provided for @gitNotRepo.
  ///
  /// In en_GB, this message translates to:
  /// **'This project is not a git repository yet.'**
  String get gitNotRepo;

  /// No description provided for @gitInit.
  ///
  /// In en_GB, this message translates to:
  /// **'Initialise git'**
  String get gitInit;

  /// No description provided for @gitChanges.
  ///
  /// In en_GB, this message translates to:
  /// **'Changes'**
  String get gitChanges;

  /// No description provided for @gitClean.
  ///
  /// In en_GB, this message translates to:
  /// **'Working tree clean'**
  String get gitClean;

  /// No description provided for @gitHistory.
  ///
  /// In en_GB, this message translates to:
  /// **'History'**
  String get gitHistory;

  /// No description provided for @commitMessage.
  ///
  /// In en_GB, this message translates to:
  /// **'Commit message'**
  String get commitMessage;

  /// No description provided for @exportInfo.
  ///
  /// In en_GB, this message translates to:
  /// **'Write the generated Flutter sources into the project folder.'**
  String get exportInfo;

  /// No description provided for @exportImportedHint.
  ///
  /// In en_GB, this message translates to:
  /// **'Imported project: only the Sunset screens and strings are written, your own code is untouched.'**
  String get exportImportedHint;

  /// No description provided for @exportButton.
  ///
  /// In en_GB, this message translates to:
  /// **'Export code'**
  String get exportButton;

  /// No description provided for @exportedFiles.
  ///
  /// In en_GB, this message translates to:
  /// **'Exported {count} files'**
  String exportedFiles(int count);

  /// No description provided for @exportTargets.
  ///
  /// In en_GB, this message translates to:
  /// **'Files written'**
  String get exportTargets;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ga', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
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
            return AppLocalizationsEnGb();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ga':
      return AppLocalizationsGa();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
