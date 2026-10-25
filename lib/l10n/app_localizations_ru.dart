// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Sunset';

  @override
  String get navDashboard => 'Панель';

  @override
  String get navSettings => 'Настройки';

  @override
  String get appearanceSection => 'Внешний вид';

  @override
  String get aboutSection => 'О программе';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeOled => 'OLED';

  @override
  String get accentColor => 'Акцентный цвет';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Системный';

  @override
  String versionLabel(String version) {
    return 'Версия $version';
  }

  @override
  String get checkUpdates => 'Проверить обновления';

  @override
  String get updateChecking => 'Проверка…';

  @override
  String get updateFailed => 'Ошибка проверки';

  @override
  String updateAvailable(String version) {
    return 'Доступна версия $version';
  }

  @override
  String get upToDate => 'Уже последняя версия';

  @override
  String getUpdate(String version) {
    return 'Получить $version';
  }

  @override
  String get releasesLink => 'Все релизы';

  @override
  String get sourceLink => 'Исходный код';

  @override
  String get newProject => 'Новый проект';

  @override
  String get importProject => 'Импорт проекта Flutter';

  @override
  String get emptyProjects =>
      'Проектов пока нет. Создайте новый или импортируйте существующий проект Flutter.';

  @override
  String get projectName => 'Название проекта';

  @override
  String get cancel => 'Отмена';

  @override
  String get create => 'Создать';

  @override
  String get removeFromList => 'Убрать из списка';

  @override
  String get importedBadge => 'Импортирован';

  @override
  String get noDirectoryPicked => 'Папка не выбрана';

  @override
  String get notFlutterProject => 'Эта папка не является проектом Flutter';

  @override
  String get backToDashboard => 'Назад к панели';

  @override
  String get addScreen => 'Добавить экран';

  @override
  String get renameScreen => 'Переименовать экран';

  @override
  String get screenName => 'Название экрана';

  @override
  String get saveProject => 'Сохранить проект';

  @override
  String get projectSaved => 'Проект сохранён';

  @override
  String get panelWidgets => 'Виджеты';

  @override
  String get panelTree => 'Дерево';

  @override
  String get panelProps => 'Свойства';

  @override
  String get panelTheme => 'Тема';

  @override
  String get panelStrings => 'Строки';

  @override
  String get panelGit => 'Git';

  @override
  String get panelExport => 'Экспорт';

  @override
  String get groupLayout => 'Разметка';

  @override
  String get groupContent => 'Содержимое';

  @override
  String get inspectorEmpty =>
      'Выберите виджет на холсте или в дереве, чтобы изменить его.';

  @override
  String get unknownWidget => 'Неизвестный тип виджета';

  @override
  String get noneOption => 'Нет';

  @override
  String get seedColor => 'Базовый цвет';

  @override
  String get brightness => 'Яркость';

  @override
  String get responsive => 'Адаптивная вёрстка';

  @override
  String get responsiveHint =>
      'Созданные экраны подстраивают отступы под ширину окна.';

  @override
  String get packageName => 'Имя пакета';

  @override
  String get locales => 'Языки';

  @override
  String get addLocale => 'Добавить язык';

  @override
  String get stringsTitle => 'Строки';

  @override
  String get addString => 'Добавить строку';

  @override
  String get stringKey => 'Ключ';

  @override
  String get gitNotRepo => 'Этот проект ещё не является git-репозиторием.';

  @override
  String get gitInit => 'Инициализировать git';

  @override
  String get gitChanges => 'Изменения';

  @override
  String get gitClean => 'Рабочее дерево чистое';

  @override
  String get gitHistory => 'История';

  @override
  String get commitMessage => 'Сообщение коммита';

  @override
  String get exportInfo =>
      'Записать сгенерированный код Flutter в папку проекта.';

  @override
  String get exportImportedHint =>
      'Импортированный проект: записываются только экраны и строки Sunset, ваш код не затрагивается.';

  @override
  String get exportButton => 'Экспортировать код';

  @override
  String exportedFiles(int count) {
    return 'Экспортировано файлов: $count';
  }

  @override
  String get exportTargets => 'Записанные файлы';
}
