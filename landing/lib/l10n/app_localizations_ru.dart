// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class LandingLocalizationsRu extends LandingLocalizations {
  LandingLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Sunset';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeOled => 'OLED';

  @override
  String get languageSystem => 'Системный';

  @override
  String get tagline => 'Визуальный конструктор Flutter';

  @override
  String get hero => 'Проектируйте Flutter-приложения без кода';

  @override
  String get sub =>
      'Размещайте виджеты на холсте, настраивайте стили, управляйте локалями и git, затем экспортируйте настоящий проект Flutter. Полноценный CLI даёт агентам те же возможности.';

  @override
  String get openApp => 'Открыть приложение';

  @override
  String get getDownloads => 'Загрузки';

  @override
  String get sourceLink => 'Исходный код';

  @override
  String get featuresTitle => 'Почему Sunset';

  @override
  String get feature1Title => 'Всё на холсте';

  @override
  String get feature1Body =>
      'Перетаскивайте виджеты в живой предпросмотр, меняйте свойства в инспекторе и смотрите, как обновляются настоящие виджеты Flutter.';

  @override
  String get feature2Title => 'Настоящий код Flutter';

  @override
  String get feature2Body =>
      'Экспорт создаёт чистый Dart: экраны, тему и файлы локализации, которые можно править вручную когда угодно.';

  @override
  String get feature3Title => 'Встроенные i18n и git';

  @override
  String get feature3Body =>
      'Управляйте локалями и строками в одной панели, привязывайте текст к ключам и делайте коммиты, не выходя из приложения.';

  @override
  String get feature4Title => 'CLI с полным паритетом';

  @override
  String get feature4Body =>
      'Любое действие редактора доступно в CLI sunset, поэтому скрипты и ИИ-агенты могут собирать те же проекты без интерфейса.';

  @override
  String get downloadsTitle => 'Загрузки';

  @override
  String get downloadsSub =>
      'Стабильные сборки для всех настольных платформ прямо из GitLab Releases.';

  @override
  String get flatpakHint => 'Flatpak в одну строку:';

  @override
  String get loadingReleases => 'Загрузка релизов…';

  @override
  String get releasesError => 'Не удалось загрузить релизы';

  @override
  String get noReleases => 'Релизов пока нет';

  @override
  String get gitlabReleases => 'Все релизы на GitLab';

  @override
  String get screensTitle => 'Внутри конструктора';
}
