import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show SynchronousFuture;

class PoLocalizations {
  PoLocalizations(this.locale);
  
  final Locale locale;
  Map<String, String> _localizedStrings = {};
  
  static PoLocalizations of(BuildContext context) {
    return Localizations.of<PoLocalizations>(context, PoLocalizations) ?? PoLocalizations(const Locale('en'));
  }
  
  Future<bool> load() async {
    try {
      // 尝试从assets加载.po文件
      String poContent = await rootBundle.loadString('lib/po/app_${locale.languageCode}.po');
      _localizedStrings = _parsePoFile(poContent);
      // 添加调试信息
      print('Loaded ${_localizedStrings.length} translations for ${locale.languageCode}');
      return true;
    } catch (e) {
      // 如果加载失败，使用空映射
      print('Failed to load translations for ${locale.languageCode}: $e');
      _localizedStrings = {};
      return false;
    }
  }
  
  // 解析.po文件内容
  Map<String, String> _parsePoFile(String content) {
    Map<String, String> translations = {};
    List<String> lines = content.split('\n');
    
    String? currentMsgId;
    String? currentMsgStr;
    bool inMsgId = false;
    bool inMsgStr = false;
    
    for (String line in lines) {
      line = line.trim();
      
      // 跳过空行和注释
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }
      
      if (line.startsWith('msgid ')) {
        inMsgId = true;
        inMsgStr = false;
        // 提取msgid的值（去除引号）
        currentMsgId = line.substring(6).replaceAll('"', '');
      } else if (line.startsWith('msgstr ')) {
        inMsgId = false;
        inMsgStr = true;
        // 提取msgstr的值（去除引号）
        currentMsgStr = line.substring(7).replaceAll('"', '');
      } else if (line.startsWith('"') && line.endsWith('"')) {
        // 处理多行字符串
        String value = line.substring(1, line.length - 1);
        if (inMsgId && currentMsgId != null) {
          currentMsgId += value;
        } else if (inMsgStr && currentMsgStr != null) {
          currentMsgStr += value;
        }
      }
      
      // 如果我们有完整的msgid和msgstr，就添加到翻译映射中
      if (currentMsgId != null && currentMsgStr != null && 
          !inMsgId && !inMsgStr && 
          currentMsgId.isNotEmpty) {
        translations[currentMsgId] = currentMsgStr;
        // 添加调试信息
        print('Added translation: $currentMsgId -> $currentMsgStr');
        currentMsgId = null;
        currentMsgStr = null;
      }
    }
    
    return translations;
  }
  
  String tr(String key) {
    String value = _localizedStrings[key] ?? key;
    // 添加调试信息
    if (value == key) {
      print('Translation not found for key: $key');
    }
    return value;
  }
  
  static const LocalizationsDelegate<PoLocalizations> delegate = _PoLocalizationsDelegate();
}

class _PoLocalizationsDelegate extends LocalizationsDelegate<PoLocalizations> {
  const _PoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // 支持英语和中文
    bool supported = ['en', 'zh'].contains(locale.languageCode);
    print('Locale ${locale.languageCode} supported: $supported');
    return supported;
  }

  @override
  Future<PoLocalizations> load(Locale locale) async {
    print('Loading translations for locale: ${locale.languageCode}');
    PoLocalizations localizations = PoLocalizations(locale);
    await localizations.load();
    print('Loaded translations for locale: ${locale.languageCode}');
    return SynchronousFuture<PoLocalizations>(localizations);
  }

  @override
  bool shouldReload(_PoLocalizationsDelegate old) => false;
}