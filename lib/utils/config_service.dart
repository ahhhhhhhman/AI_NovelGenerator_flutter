import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  Map<String, dynamic>? _config;

  /// 初始化配置文件
  /// 在应用启动时调用，检查是否存在config.json，如果不存在则从config.example.json复制
  Future<void> init() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final configPath = path.join(appDocDir.path, 'config.json');
      final configFile = File(configPath);

      // 检查config.json是否存在
      if (!await configFile.exists()) {
        // 从assets中读取config.example.json
        final exampleConfig = await rootBundle.loadString('config.example.json');
        
        // 写入到应用文档目录
        await configFile.writeAsString(exampleConfig);
        print('Created config.json from config.example.json');
      }

      // 读取配置文件
      final configString = await configFile.readAsString();
      _config = json.decode(configString);
      print('Configuration loaded successfully');
    } catch (e) {
      print('Error initializing configuration: $e');
      // 使用默认配置
      _config = {
          "last_interface_format": "OpenAI",
          "last_embedding_interface_format": "OpenAI",
          "llm_configs": {
              "DeepSeek V3": {
                  "api_key": "",
                  "base_url": "https://api.deepseek.com/v1",
                  "model_name": "deepseek-chat",
                  "temperature": 0.7,
                  "max_tokens": 8192,
                  "timeout": 600,
                  "interface_format": "OpenAI"
              },
              "GPT 5": {
                  "api_key": "",
                  "base_url": "https://api.openai.com/v1",
                  "model_name": "gpt-5",
                  "temperature": 0.7,
                  "max_tokens": 32768,
                  "timeout": 600,
                  "interface_format": "OpenAI"
              },
              "Gemini 2.5 Pro": {
                  "api_key": "",
                  "base_url": "https://generativelanguage.googleapis.com/v1beta/openai",
                  "model_name": "gemini-2.5-pro",
                  "temperature": 0.7,
                  "max_tokens": 32768,
                  "timeout": 600,
                  "interface_format": "OpenAI"
              }
          },
          "embedding_configs": {
              "OpenAI": {
                  "api_key": "",
                  "base_url": "https://api.openai.com/v1",
                  "model_name": "text-embedding-ada-002",
                  "retrieval_k": 4,
                  "interface_format": "OpenAI"
              }
          },
          "other_params": {
              "topic": "",
              "genre": "",
              "num_chapters": 0,
              "word_number": 0,
              "filepath": "",
              "chapter_num": "120",
              "user_guidance": "",
              "characters_involved": "",
              "key_items": "",
              "scene_location": "",
              "time_constraint": ""
          },
          "choose_configs": {
              "prompt_draft_llm": "DeepSeek V3",
              "chapter_outline_llm": "DeepSeek V3",
              "architecture_llm": "Gemini 2.5 Pro",
              "final_chapter_llm": "GPT 5",
              "consistency_review_llm": "DeepSeek V3"
          },
          "proxy_setting": {
              "proxy_url": "127.0.0.1",
              "proxy_port": "",
              "enabled": false
          },
          "webdav_config": {
              "webdav_url": "",
              "webdav_username": "",
              "webdav_password": ""
          }
      };
    }
  }

  /// 获取配置值
  dynamic get(String key) {
    if (_config == null) return null;
    
    // 支持点号分隔的嵌套键，例如 "default_settings.theme"
    final keys = key.split('.');
    dynamic value = _config;
    
    for (final k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return null;
      }
    }
    
    return value;
  }

  /// 获取整个配置对象
  Map<String, dynamic>? getAll() {
    return _config;
  }

  /// 更新配置值
  Future<void> set(String key, dynamic value) async {
    if (_config == null) return;
    
    // 支持点号分隔的嵌套键
    final keys = key.split('.');
    dynamic config = _config;
    
    for (int i = 0; i < keys.length - 1; i++) {
      final k = keys[i];
      if (!config.containsKey(k) || config[k] is! Map) {
        config[k] = {};
      }
      config = config[k];
    }
    
    config[keys.last] = value;
    
    // 保存到文件
    await _saveConfig();
  }

  /// 保存配置到文件
  Future<void> _saveConfig() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final configPath = path.join(appDocDir.path, 'config.json');
      final configFile = File(configPath);
      
      final configString = json.encode(_config);
      await configFile.writeAsString(configString);
      print('Configuration saved successfully');
    } catch (e) {
      print('Error saving configuration: $e');
    }
  }
}