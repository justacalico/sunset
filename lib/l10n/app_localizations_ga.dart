// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Irish (`ga`).
class AppLocalizationsGa extends AppLocalizations {
  AppLocalizationsGa([String locale = 'ga']) : super(locale);

  @override
  String get appTitle => 'Sunset';

  @override
  String get navDashboard => 'Deais';

  @override
  String get navSettings => 'Socruithe';

  @override
  String get appearanceSection => 'Cuma';

  @override
  String get aboutSection => 'Faoi';

  @override
  String get theme => 'Téama';

  @override
  String get themeSystem => 'Córas';

  @override
  String get themeLight => 'Éadrom';

  @override
  String get themeDark => 'Dorcha';

  @override
  String get themeOled => 'OLED';

  @override
  String get accentColor => 'Dath béime';

  @override
  String get language => 'Teanga';

  @override
  String get languageSystem => 'Córas';

  @override
  String versionLabel(String version) {
    return 'Leagan $version';
  }

  @override
  String get checkUpdates => 'Seiceáil le haghaidh nuashonruithe';

  @override
  String get updateChecking => 'Á sheiceáil…';

  @override
  String get updateFailed => 'Theip ar an seiceáil';

  @override
  String updateAvailable(String version) {
    return 'Tá leagan $version ar fáil';
  }

  @override
  String get upToDate => 'Nuashonraithe';

  @override
  String getUpdate(String version) {
    return 'Faigh $version';
  }

  @override
  String get releasesLink => 'Gach eisiúint';

  @override
  String get sourceLink => 'Cód foinse';

  @override
  String get newProject => 'Tionscadal nua';

  @override
  String get importProject => 'Iompórtáil tionscadal Flutter';

  @override
  String get emptyProjects =>
      'Níl aon tionscadal ann fós. Cruthaigh ceann nó iompórtáil tionscadal Flutter atá ann cheana.';

  @override
  String get projectName => 'Ainm an tionscadail';

  @override
  String get cancel => 'Cealaigh';

  @override
  String get create => 'Cruthaigh';

  @override
  String get removeFromList => 'Bain den liosta';

  @override
  String get importedBadge => 'Iompórtáilte';

  @override
  String get noDirectoryPicked => 'Níor roghnaíodh fillteán';

  @override
  String get notFlutterProject => 'Ní tionscadal Flutter é an fillteán sin';

  @override
  String get backToDashboard => 'Ar ais go dtí an deais';

  @override
  String get addScreen => 'Cuir scáileán leis';

  @override
  String get renameScreen => 'Athainmnigh an scáileán';

  @override
  String get screenName => 'Ainm an scáileáin';

  @override
  String get saveProject => 'Sábháil an tionscadal';

  @override
  String get projectSaved => 'Tionscadal sábháilte';

  @override
  String get panelWidgets => 'Giúirléidí';

  @override
  String get panelTree => 'Crann';

  @override
  String get panelProps => 'Airíonna';

  @override
  String get panelTheme => 'Téama';

  @override
  String get panelStrings => 'Teaghráin';

  @override
  String get panelGit => 'Git';

  @override
  String get panelExport => 'Easpórtáil';

  @override
  String get groupLayout => 'Leagan amach';

  @override
  String get groupContent => 'Ábhar';

  @override
  String get inspectorEmpty =>
      'Roghnaigh giúirléid ar an chanbhás nó sa chrann chun í a chur in eagar.';

  @override
  String get unknownWidget => 'Cineál giúirléide anaithnid';

  @override
  String get noneOption => 'Dada';

  @override
  String get seedColor => 'Dath síl';

  @override
  String get brightness => 'Gile';

  @override
  String get responsive => 'Leagan amach sofhreagrach';

  @override
  String get responsiveHint =>
      'Oireann na scáileáin ginte a bhfástaí do leithead an fhuinneoga.';

  @override
  String get packageName => 'Ainm an phacáiste';

  @override
  String get locales => 'Locales';

  @override
  String get addLocale => 'Cuir locale leis';

  @override
  String get stringsTitle => 'Teaghráin';

  @override
  String get addString => 'Cuir teaghrán leis';

  @override
  String get stringKey => 'Eochair';

  @override
  String get gitNotRepo => 'Níl an tionscadal seo ina stór git fós.';

  @override
  String get gitInit => 'Tosaigh git';

  @override
  String get gitChanges => 'Athruithe';

  @override
  String get gitClean => 'Crann oibre glan';

  @override
  String get gitHistory => 'Stair';

  @override
  String get commitMessage => 'Teachtaireacht commit';

  @override
  String get exportInfo =>
      'Scríobh an cód Flutter ginte isteach i bhfillteán an tionscadail.';

  @override
  String get exportImportedHint =>
      'Tionscadal iompórtáilte: ní scríobhtar ach scáileáin agus teaghráin Sunset, ní bhaintear le do chód féin.';

  @override
  String get exportButton => 'Easpórtáil an cód';

  @override
  String exportedFiles(int count) {
    return 'Easpórtáladh $count comhad';
  }

  @override
  String get exportTargets => 'Comhaid scríofa';
}
