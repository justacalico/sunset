// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Sunset';

  @override
  String get navDashboard => '仪表盘';

  @override
  String get navSettings => '设置';

  @override
  String get appearanceSection => '外观';

  @override
  String get aboutSection => '关于';

  @override
  String get theme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeOled => 'OLED';

  @override
  String get accentColor => '强调色';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String versionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get checkUpdates => '检查更新';

  @override
  String get updateChecking => '正在检查…';

  @override
  String get updateFailed => '检查失败';

  @override
  String updateAvailable(String version) {
    return '新版本 $version 可用';
  }

  @override
  String get upToDate => '已是最新';

  @override
  String getUpdate(String version) {
    return '获取 $version';
  }

  @override
  String get releasesLink => '所有版本';

  @override
  String get sourceLink => '源代码';

  @override
  String get newProject => '新建项目';

  @override
  String get importProject => '导入 Flutter 项目';

  @override
  String get emptyProjects => '还没有项目。新建一个，或导入已有的 Flutter 项目。';

  @override
  String get projectName => '项目名称';

  @override
  String get cancel => '取消';

  @override
  String get create => '创建';

  @override
  String get removeFromList => '从列表移除';

  @override
  String get importedBadge => '已导入';

  @override
  String get noDirectoryPicked => '未选择文件夹';

  @override
  String get notFlutterProject => '该文件夹不是 Flutter 项目';

  @override
  String get backToDashboard => '返回仪表盘';

  @override
  String get addScreen => '添加页面';

  @override
  String get renameScreen => '重命名页面';

  @override
  String get screenName => '页面名称';

  @override
  String get saveProject => '保存项目';

  @override
  String get projectSaved => '项目已保存';

  @override
  String get panelWidgets => '组件';

  @override
  String get panelTree => '树';

  @override
  String get panelProps => '属性';

  @override
  String get panelTheme => '主题';

  @override
  String get panelStrings => '字符串';

  @override
  String get panelGit => 'Git';

  @override
  String get panelExport => '导出';

  @override
  String get groupLayout => '布局';

  @override
  String get groupContent => '内容';

  @override
  String get inspectorEmpty => '在画布或树中选择一个组件即可编辑。';

  @override
  String get unknownWidget => '未知的组件类型';

  @override
  String get noneOption => '无';

  @override
  String get seedColor => '种子颜色';

  @override
  String get brightness => '亮度';

  @override
  String get responsive => '响应式布局';

  @override
  String get responsiveHint => '生成的页面会随窗口宽度自适应内边距。';

  @override
  String get packageName => '包名';

  @override
  String get locales => '语言环境';

  @override
  String get addLocale => '添加语言';

  @override
  String get stringsTitle => '字符串';

  @override
  String get addString => '添加字符串';

  @override
  String get stringKey => '键';

  @override
  String get gitNotRepo => '该项目还不是 git 仓库。';

  @override
  String get gitInit => '初始化 git';

  @override
  String get gitChanges => '变更';

  @override
  String get gitClean => '工作区干净';

  @override
  String get gitHistory => '历史';

  @override
  String get commitMessage => '提交信息';

  @override
  String get exportInfo => '将生成的 Flutter 源码写入项目文件夹。';

  @override
  String get exportImportedHint => '导入的项目：只写入 Sunset 的页面和字符串，不改动你自己的代码。';

  @override
  String get exportButton => '导出代码';

  @override
  String exportedFiles(int count) {
    return '已导出 $count 个文件';
  }

  @override
  String get exportTargets => '写入的文件';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => 'Sunset';

  @override
  String get navDashboard => '仪表盘';

  @override
  String get navSettings => '设置';

  @override
  String get appearanceSection => '外观';

  @override
  String get aboutSection => '关于';

  @override
  String get theme => '主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeOled => 'OLED';

  @override
  String get accentColor => '强调色';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String versionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get checkUpdates => '检查更新';

  @override
  String get updateChecking => '正在检查…';

  @override
  String get updateFailed => '检查失败';

  @override
  String updateAvailable(String version) {
    return '新版本 $version 可用';
  }

  @override
  String get upToDate => '已是最新';

  @override
  String getUpdate(String version) {
    return '获取 $version';
  }

  @override
  String get releasesLink => '所有版本';

  @override
  String get sourceLink => '源代码';

  @override
  String get newProject => '新建项目';

  @override
  String get importProject => '导入 Flutter 项目';

  @override
  String get emptyProjects => '还没有项目。新建一个，或导入已有的 Flutter 项目。';

  @override
  String get projectName => '项目名称';

  @override
  String get cancel => '取消';

  @override
  String get create => '创建';

  @override
  String get removeFromList => '从列表移除';

  @override
  String get importedBadge => '已导入';

  @override
  String get noDirectoryPicked => '未选择文件夹';

  @override
  String get notFlutterProject => '该文件夹不是 Flutter 项目';

  @override
  String get backToDashboard => '返回仪表盘';

  @override
  String get addScreen => '添加页面';

  @override
  String get renameScreen => '重命名页面';

  @override
  String get screenName => '页面名称';

  @override
  String get saveProject => '保存项目';

  @override
  String get projectSaved => '项目已保存';

  @override
  String get panelWidgets => '组件';

  @override
  String get panelTree => '树';

  @override
  String get panelProps => '属性';

  @override
  String get panelTheme => '主题';

  @override
  String get panelStrings => '字符串';

  @override
  String get panelGit => 'Git';

  @override
  String get panelExport => '导出';

  @override
  String get groupLayout => '布局';

  @override
  String get groupContent => '内容';

  @override
  String get inspectorEmpty => '在画布或树中选择一个组件即可编辑。';

  @override
  String get unknownWidget => '未知的组件类型';

  @override
  String get noneOption => '无';

  @override
  String get seedColor => '种子颜色';

  @override
  String get brightness => '亮度';

  @override
  String get responsive => '响应式布局';

  @override
  String get responsiveHint => '生成的页面会随窗口宽度自适应内边距。';

  @override
  String get packageName => '包名';

  @override
  String get locales => '语言环境';

  @override
  String get addLocale => '添加语言';

  @override
  String get stringsTitle => '字符串';

  @override
  String get addString => '添加字符串';

  @override
  String get stringKey => '键';

  @override
  String get gitNotRepo => '该项目还不是 git 仓库。';

  @override
  String get gitInit => '初始化 git';

  @override
  String get gitChanges => '变更';

  @override
  String get gitClean => '工作区干净';

  @override
  String get gitHistory => '历史';

  @override
  String get commitMessage => '提交信息';

  @override
  String get exportInfo => '将生成的 Flutter 源码写入项目文件夹。';

  @override
  String get exportImportedHint => '导入的项目：只写入 Sunset 的页面和字符串，不改动你自己的代码。';

  @override
  String get exportButton => '导出代码';

  @override
  String exportedFiles(int count) {
    return '已导出 $count 个文件';
  }

  @override
  String get exportTargets => '写入的文件';
}
