// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sunset';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navSettings => 'Settings';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get aboutSection => 'About';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeOled => 'OLED';

  @override
  String get accentColor => 'Accent colour';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get updateChecking => 'Checking…';

  @override
  String get updateFailed => 'Check failed';

  @override
  String updateAvailable(String version) {
    return 'Version $version is available';
  }

  @override
  String get upToDate => 'Up to date';

  @override
  String getUpdate(String version) {
    return 'Get $version';
  }

  @override
  String get releasesLink => 'All releases';

  @override
  String get sourceLink => 'Source code';

  @override
  String get newProject => 'New project';

  @override
  String get importProject => 'Import Flutter project';

  @override
  String get emptyProjects =>
      'No projects yet. Create one or import an existing Flutter project.';

  @override
  String get projectName => 'Project name';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get removeFromList => 'Remove from list';

  @override
  String get importedBadge => 'Imported';

  @override
  String get noDirectoryPicked => 'No folder picked';

  @override
  String get notFlutterProject => 'That folder is not a Flutter project';

  @override
  String get backToDashboard => 'Back to dashboard';

  @override
  String get addScreen => 'Add screen';

  @override
  String get renameScreen => 'Rename screen';

  @override
  String get screenName => 'Screen name';

  @override
  String get saveProject => 'Save project';

  @override
  String get projectSaved => 'Project saved';

  @override
  String get panelWidgets => 'Widgets';

  @override
  String get panelTree => 'Tree';

  @override
  String get panelProps => 'Props';

  @override
  String get panelTheme => 'Theme';

  @override
  String get panelStrings => 'Strings';

  @override
  String get panelGit => 'Git';

  @override
  String get panelExport => 'Export';

  @override
  String get groupLayout => 'Layout';

  @override
  String get groupContent => 'Content';

  @override
  String get inspectorEmpty =>
      'Select a widget on the canvas or in the tree to edit it.';

  @override
  String get unknownWidget => 'Unknown widget type';

  @override
  String get noneOption => 'None';

  @override
  String get seedColor => 'Seed colour';

  @override
  String get brightness => 'Brightness';

  @override
  String get responsive => 'Responsive layout';

  @override
  String get responsiveHint =>
      'Generated screens adapt their padding to the window width.';

  @override
  String get packageName => 'Package name';

  @override
  String get locales => 'Locales';

  @override
  String get addLocale => 'Add locale';

  @override
  String get stringsTitle => 'Strings';

  @override
  String get addString => 'Add string';

  @override
  String get stringKey => 'Key';

  @override
  String get gitNotRepo => 'This project is not a git repository yet.';

  @override
  String get gitInit => 'Initialise git';

  @override
  String get gitChanges => 'Changes';

  @override
  String get gitClean => 'Working tree clean';

  @override
  String get gitHistory => 'History';

  @override
  String get commitMessage => 'Commit message';

  @override
  String get exportInfo =>
      'Write the generated Flutter sources into the project folder.';

  @override
  String get exportImportedHint =>
      'Imported project: only the Sunset screens and strings are written, your own code is untouched.';

  @override
  String get exportButton => 'Export code';

  @override
  String exportedFiles(int count) {
    return 'Exported $count files';
  }

  @override
  String get exportTargets => 'Files written';
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class AppLocalizationsEnGb extends AppLocalizationsEn {
  AppLocalizationsEnGb() : super('en_GB');

  @override
  String get appTitle => 'Sunset';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navSettings => 'Settings';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get aboutSection => 'About';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeOled => 'OLED';

  @override
  String get accentColor => 'Accent colour';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get updateChecking => 'Checking…';

  @override
  String get updateFailed => 'Check failed';

  @override
  String updateAvailable(String version) {
    return 'Version $version is available';
  }

  @override
  String get upToDate => 'Up to date';

  @override
  String getUpdate(String version) {
    return 'Get $version';
  }

  @override
  String get releasesLink => 'All releases';

  @override
  String get sourceLink => 'Source code';

  @override
  String get newProject => 'New project';

  @override
  String get importProject => 'Import Flutter project';

  @override
  String get emptyProjects =>
      'No projects yet. Create one or import an existing Flutter project.';

  @override
  String get projectName => 'Project name';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get removeFromList => 'Remove from list';

  @override
  String get importedBadge => 'Imported';

  @override
  String get noDirectoryPicked => 'No folder picked';

  @override
  String get notFlutterProject => 'That folder is not a Flutter project';

  @override
  String get backToDashboard => 'Back to dashboard';

  @override
  String get addScreen => 'Add screen';

  @override
  String get renameScreen => 'Rename screen';

  @override
  String get screenName => 'Screen name';

  @override
  String get saveProject => 'Save project';

  @override
  String get projectSaved => 'Project saved';

  @override
  String get panelWidgets => 'Widgets';

  @override
  String get panelTree => 'Tree';

  @override
  String get panelProps => 'Props';

  @override
  String get panelTheme => 'Theme';

  @override
  String get panelStrings => 'Strings';

  @override
  String get panelGit => 'Git';

  @override
  String get panelExport => 'Export';

  @override
  String get groupLayout => 'Layout';

  @override
  String get groupContent => 'Content';

  @override
  String get inspectorEmpty =>
      'Select a widget on the canvas or in the tree to edit it.';

  @override
  String get unknownWidget => 'Unknown widget type';

  @override
  String get noneOption => 'None';

  @override
  String get seedColor => 'Seed colour';

  @override
  String get brightness => 'Brightness';

  @override
  String get responsive => 'Responsive layout';

  @override
  String get responsiveHint =>
      'Generated screens adapt their padding to the window width.';

  @override
  String get packageName => 'Package name';

  @override
  String get locales => 'Locales';

  @override
  String get addLocale => 'Add locale';

  @override
  String get stringsTitle => 'Strings';

  @override
  String get addString => 'Add string';

  @override
  String get stringKey => 'Key';

  @override
  String get gitNotRepo => 'This project is not a git repository yet.';

  @override
  String get gitInit => 'Initialise git';

  @override
  String get gitChanges => 'Changes';

  @override
  String get gitClean => 'Working tree clean';

  @override
  String get gitHistory => 'History';

  @override
  String get commitMessage => 'Commit message';

  @override
  String get exportInfo =>
      'Write the generated Flutter sources into the project folder.';

  @override
  String get exportImportedHint =>
      'Imported project: only the Sunset screens and strings are written, your own code is untouched.';

  @override
  String get exportButton => 'Export code';

  @override
  String exportedFiles(int count) {
    return 'Exported $count files';
  }

  @override
  String get exportTargets => 'Files written';
}
