// 修正这里！使用 'package:' 而不是相对路径
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class PoLocalizations {
  PoLocalizations(this.locale);

  final Locale locale;
  late Map<String, String> _localizedStrings;

  static PoLocalizations of(BuildContext context) {
    return Localizations.of<PoLocalizations>(context, PoLocalizations)!;
  }

  Future<bool> load() async {
    String assetPath =
        'lib/po/translations/${locale.languageCode}/LC_MESSAGES/messages.po';

    try {
      print('正在加载翻译文件: $assetPath');
      String poContent = await rootBundle.loadString(assetPath);
      _localizedStrings = _parsePoFile(poContent);
      print('成功为 ${locale.languageCode} 加载了 ${_localizedStrings.length} 条翻译。');
      return true;
    } catch (e) {
      print('错误：为 ${locale.languageCode} 加载翻译失败，路径: $assetPath. $e');
      _localizedStrings = {};
      return false;
    }
  }

  Map<String, String> _parsePoFile(String content) {
    final Map<String, String> translations = {};

    final entries = content.split(RegExp(r'\n\s*\n'));

    for (final entry in entries) {
      final lines = entry.split('\n');
      String? msgid;
      String msgstr = '';
      bool inMsgId = false;
      bool inMsgStr = false;

      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
          continue;
        }

        if (trimmedLine.startsWith('msgid ')) {
          inMsgId = true;
          inMsgStr = false;
          msgid = _unquote(trimmedLine.substring(6));
        } else if (trimmedLine.startsWith('msgstr ')) {
          inMsgId = false;
          inMsgStr = true;
          msgstr = _unquote(trimmedLine.substring(7));
        } else if (trimmedLine.startsWith('"')) {
          if (inMsgId) {
            msgid = (msgid ?? '') + _unquote(trimmedLine);
          } else if (inMsgStr) {
            msgstr += _unquote(trimmedLine);
          }
        }
      }

      if (msgid != null && msgid.isNotEmpty) {
        translations[msgid] = msgstr;
      }
    }

    return translations;
  }

  String _unquote(String str) {
    if (str.startsWith('"') && str.endsWith('"')) {
      return str.substring(1, str.length - 1);
    }
    return str;
  }

  String tr(String key) {
    final translation = _localizedStrings[key];
    if (translation == null) {
      print('翻译未找到：key: "$key", 语言: "${locale.languageCode}".');
      return key;
    }
    return translation;
  }

  static const LocalizationsDelegate<PoLocalizations> delegate =
      _PoLocalizationsDelegate();
}

class _PoLocalizationsDelegate extends LocalizationsDelegate<PoLocalizations> {
  const _PoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<PoLocalizations> load(Locale locale) async {
    print('开始为语言环境加载翻译: ${locale.languageCode}');
    PoLocalizations localizations = PoLocalizations(locale);
    await localizations.load();
    print('完成为语言环境加载翻译: ${locale.languageCode}');
    return localizations;
  }

  @override
  bool shouldReload(_PoLocalizationsDelegate old) => false;
}
