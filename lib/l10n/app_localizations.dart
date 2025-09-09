import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  // 静态方法用于获取当前的AppLocalizations实例
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // 缓存资源
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    // 加载对应的ARB文件
    String jsonString = await rootBundle.loadString('lib/l10n/app_${locale.languageCode}.arb');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // 用于获取翻译文本的函数
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // 翻译键的便捷方法
  String get appTitle => translate('appTitle');
  String get homeTab => translate('homeTab');
  String get generatorTab => translate('generatorTab');
  String get favoritesTab => translate('favoritesTab');
  String get settingsTab => translate('settingsTab');
  String get profileTab => translate('profileTab');
  String get searchTab => translate('searchTab');
  String get helpTab => translate('helpTab');
  String get homeContent => translate('homeContent');
  String get favoritesContent => translate('favoritesContent');
  String get settingsContent => translate('settingsContent');
  String get profileContent => translate('profileContent');
  String get searchContent => translate('searchContent');
  String get helpContent => translate('helpContent');
  String get likeButton => translate('likeButton');
  String get nextButton => translate('nextButton');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // 支持英语和中文
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}