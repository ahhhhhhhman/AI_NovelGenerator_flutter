import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'config_service.dart';
import '../domain/services/logger_service.dart';

class WebDAVService {
  static final WebDAVService _instance = WebDAVService._internal();
  factory WebDAVService() => _instance;
  WebDAVService._internal();

  webdav.Client? _client;
  bool _isInitialized = false;

  /// 初始化WebDAV客户端
  Future<void> init() async {
    try {
      final config = ConfigService().getAll();
      if (config != null && config.containsKey('webdav_config')) {
        final webdavConfig = config['webdav_config'];
        final url = webdavConfig['webdav_url'];
        final username = webdavConfig['webdav_username'];
        final password = webdavConfig['webdav_password'];

        if (url != null &&
            username != null &&
            password != null &&
            url.isNotEmpty) {
          _client = webdav.newClient(
            url,
            user: username,
            password: password,
            debug: false,
          );
          _isInitialized = true;
          LoggerService().logInfo('WebDAV client initialized successfully with URL: $url');
        } else {
          LoggerService().logWarning('WebDAV configuration is incomplete');
        }
      } else {
        LoggerService().logWarning('WebDAV configuration not found');
      }
    } catch (e) {
      _isInitialized = false;
      LoggerService().logError('Failed to initialize WebDAV client: $e');
      rethrow;
    }
  }

  /// 测试WebDAV连接
  Future<bool> testConnection() async {
    if (!_isInitialized || _client == null) {
      await init();
    }

    if (_client == null) {
      LoggerService().logWarning('WebDAV client is not initialized for connection test');
      return false;
    }

    try {
      await _client!.readDir('/');
      LoggerService().logInfo('WebDAV connection test successful');
      return true;
    } catch (e) {
      LoggerService().logError('WebDAV connection test failed: $e');
      return false;
    }
  }

  /// 备份配置文件到WebDAV
  Future<bool> backupConfig() async {
    if (!_isInitialized || _client == null) {
      await init();
    }

    if (_client == null) {
      LoggerService().logWarning('WebDAV client is not initialized for backup');
      return false;
    }

    try {
      // 获取本地配置文件路径
      final appDocDir = await getApplicationDocumentsDirectory();
      final localConfigPath = path.join(appDocDir.path, 'config.json');
      final localConfigFile = File(localConfigPath);

      if (!await localConfigFile.exists()) {
        LoggerService().logError('Local config file not found for backup');
        return false;
      }

      // 创建备份目录
      final backupDir = 'ai_novel_generator_flutter';
      try {
        await _client!.readDir(backupDir);
      } catch (e) {
        // 目录不存在则创建
        await _client!.mkdirAll(backupDir);
        LoggerService().logInfo('Created WebDAV backup directory: $backupDir');
      }

      // 上传当前配置文件
      final remoteConfigPath = '$backupDir/config.json';
      await _client!.writeFromFile(localConfigPath, remoteConfigPath);
      LoggerService().logInfo('Config file backed up to WebDAV: $remoteConfigPath');

      // 重命名本地配置文件为备份文件
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFileName = 'config_${timestamp}_bak.json';
      final localBackupPath = path.join(appDocDir.path, backupFileName);
      await localConfigFile.copy(localBackupPath);
      LoggerService().logInfo('Local config backup created: $backupFileName');

      return true;
    } catch (e) {
      LoggerService().logError('Failed to backup config to WebDAV: $e');
      return false;
    }
  }

  /// 从WebDAV恢复配置文件
  Future<bool> restoreConfig() async {
    if (!_isInitialized || _client == null) {
      await init();
    }

    if (_client == null) {
      LoggerService().logWarning('WebDAV client is not initialized for restore');
      return false;
    }

    try {
      // 获取本地配置文件路径
      final appDocDir = await getApplicationDocumentsDirectory();
      final localConfigPath = path.join(appDocDir.path, 'config.json');
      final localConfigFile = File(localConfigPath);

      // 上传当前配置文件作为恢复前的备份
      if (await localConfigFile.exists()) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final backupFileName = 'config_${timestamp}_res.json';
        final remoteBackupPath = 'ai_novel_generator_flutter/$backupFileName';
        await _client!.writeFromFile(localConfigPath, remoteBackupPath);
        LoggerService().logInfo('Current config backed up to WebDAV before restore: $backupFileName');
      }

      // 从WebDAV下载配置文件
      final remoteConfigPath = 'ai_novel_generator_flutter/config.json';
      await _client!.read2File(remoteConfigPath, localConfigPath);
      LoggerService().logInfo('Config file restored from WebDAV: $remoteConfigPath');

      return true;
    } catch (e) {
      LoggerService().logError('Failed to restore config from WebDAV: $e');
      return false;
    }
  }
}
