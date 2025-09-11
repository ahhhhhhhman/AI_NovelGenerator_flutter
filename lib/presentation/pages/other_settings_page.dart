import 'package:flutter/material.dart';
import 'dart:async';
import '../../app/localizations/app_localizations.dart';
import '../../utils/config_service.dart';
import '../../utils/webdav_service.dart';
import '../../domain/services/logger_service.dart';

class OtherSettingsPage extends StatefulWidget {
  const OtherSettingsPage({super.key});

  @override
  State<OtherSettingsPage> createState() => _OtherSettingsPageState();
}

class _OtherSettingsPageState extends State<OtherSettingsPage> {
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Timer? _debounceTimer;

  bool _isTesting = false;
  bool _isBackuping = false;
  bool _isRestoring = false;
  String _testResult = '';
  String _backupResult = '';
  String _restoreResult = '';

  @override
  void initState() {
    super.initState();
    _loadWebDAVConfig();
  }

  /// 加载WebDAV配置
  Future<void> _loadWebDAVConfig() async {
    final config = ConfigService().getAll();
    if (config != null && config.containsKey('webdav_config')) {
      final webdavConfig = config['webdav_config'];
      setState(() {
        _urlController.text = webdavConfig['webdav_url'] ?? '';
        _usernameController.text = webdavConfig['webdav_username'] ?? '';
        _passwordController.text = webdavConfig['webdav_password'] ?? '';
      });
    }
  }

  /// 保存WebDAV配置
  Future<void> saveWebDAVConfig() async {
    // 收集配置服务实例
    final configService = ConfigService();
    
    // 设置所有WebDAV配置项但不立即保存
    await configService.set('webdav_config.webdav_url', _urlController.text, saveToFile: false);
    await configService.set('webdav_config.webdav_username', _usernameController.text, saveToFile: false);
    await configService.set('webdav_config.webdav_password', _passwordController.text, saveToFile: false);
    
    // 手动触发一次保存
    await configService.set('webdav_config', configService.get('webdav_config'));
    
    LoggerService().logInfo('WebDAV configuration saved');
    
    // 显示保存成功的提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('webdav_config_saved')),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 防抖保存WebDAV配置
  void _debounceSaveWebDAVConfig() {
    // 取消之前的定时器
    _debounceTimer?.cancel();
    
    // 启动新的定时器
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      // 检查widget是否仍然挂载
      if (mounted) {
        saveWebDAVConfig();
      }
    });
  }

  /// 测试WebDAV连接
  Future<void> _testConnection(
    AppLocalizations localizations,
    BuildContext context,
  ) async {
    if (_isTesting) return;

    setState(() {
      _isTesting = true;
      _testResult = '';
    });

    String result = '';
    bool success = false;
    try {
      // 先保存配置
      await saveWebDAVConfig();

      // 测试连接
      LoggerService().logInfo('Starting WebDAV connection test');
      success = await WebDAVService().testConnection();
      result = success
          ? localizations.translate('webdav_connection_successful')
          : localizations.translate('webdav_connection_failed');
      
      LoggerService().logInfo('WebDAV connection test result: ${success ? "successful" : "failed"}');
    } catch (e) {
      LoggerService().logError('Error during WebDAV connection test: $e');
      result = 'Error: ${e.toString()}';
    }

    // 检查widget是否仍然挂载
    if (!context.mounted) return;

    setState(() {
      _testResult = result;
      _isTesting = false;
    });
  }

  /// 备份配置到WebDAV
  Future<void> _backupConfig(
    AppLocalizations localizations,
    BuildContext context,
  ) async {
    if (_isBackuping) return;

    setState(() {
      _isBackuping = true;
      _backupResult = '';
    });

    String result = '';
    bool success = false;
    try {
      // 先保存配置
      await saveWebDAVConfig();

      // 执行备份
      LoggerService().logInfo('Starting WebDAV backup operation');
      success = await WebDAVService().backupConfig();
      result = success
          ? localizations.translate('webdav_backup_successful')
          : localizations.translate('webdav_backup_failed');
      
      LoggerService().logInfo('WebDAV backup result: ${success ? "successful" : "failed"}');
    } catch (e) {
      LoggerService().logError('Error during WebDAV backup: $e');
      result = 'Error: ${e.toString()}';
    }

    // 检查widget是否仍然挂载
    if (!context.mounted) return;

    setState(() {
      _backupResult = result;
      _isBackuping = false;
    });
  }

  /// 从WebDAV恢复配置
  Future<void> _restoreConfig(
    AppLocalizations localizations,
    BuildContext context,
  ) async {
    if (_isRestoring) return;

    setState(() {
      _isRestoring = true;
      _restoreResult = '';
    });

    String result = '';
    bool success = false;
    try {
      // 先保存配置
      await saveWebDAVConfig();

      // 确认操作
      if (!context.mounted) return;
      final shouldProceed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(localizations.translate('webdav_confirm_restore')),
          content: Text(
            localizations.translate('webdav_confirm_restore_message'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(localizations.translate('webdav_cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(localizations.translate('webdav_restore_button')),
            ),
          ],
        ),
      );

      if (shouldProceed == true) {
        // 执行恢复
        LoggerService().logInfo('Starting WebDAV restore operation');
        success = await WebDAVService().restoreConfig();
        result = success
            ? localizations.translate('webdav_restore_successful')
            : localizations.translate('webdav_restore_failed');
        
        LoggerService().logInfo('WebDAV restore result: ${success ? "successful" : "failed"}');
      }
    } catch (e) {
      LoggerService().logError('Error during WebDAV restore: $e');
      result = 'Error: ${e.toString()}';
    }

    // 检查widget是否仍然挂载
    if (!context.mounted) return;

    setState(() {
      _restoreResult = result;
      _isRestoring = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WebDAV设置部分
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('webdav_backup_restore_title'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('webdav_url'),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _debounceSaveWebDAVConfig(),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('webdav_username'),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _debounceSaveWebDAVConfig(),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('webdav_password'),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      onChanged: (_) => _debounceSaveWebDAVConfig(),
                    ),
                    SizedBox(height: 16),
                    // 按钮行 - 使用Flexible确保在小屏幕上也能正确显示
                    Row(
                      children: [
                        Flexible(
                          child: ElevatedButton(
                            onPressed: _isTesting
                                ? null
                                : () => _testConnection(localizations, context),
                            child: _isTesting
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    localizations.translate(
                                      'webdav_test_connection',
                                    ),
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: _isBackuping
                                ? null
                                : () => _backupConfig(localizations, context),
                            child: _isBackuping
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    localizations.translate('webdav_backup'),
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: _isRestoring
                                ? null
                                : () => _restoreConfig(localizations, context),
                            child: _isRestoring
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    localizations.translate('webdav_restore'),
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    // 结果显示行 - 只有当有结果时才显示间距和文本
                    if (_testResult.isNotEmpty ||
                        _backupResult.isNotEmpty ||
                        _restoreResult.isNotEmpty) ...[
                      SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_testResult.isNotEmpty)
                            Text(
                              _testResult,
                              style: TextStyle(
                                color:
                                    _testResult.contains('Error') ||
                                        _testResult.contains('失败')
                                    ? Colors.red
                                    : (_testResult.contains('成功')
                                          ? Colors.green
                                          : null),
                              ),
                            ),
                          if (_testResult.isNotEmpty &&
                              (_backupResult.isNotEmpty ||
                                  _restoreResult.isNotEmpty))
                            SizedBox(height: 8),
                          if (_backupResult.isNotEmpty)
                            Text(
                              _backupResult,
                              style: TextStyle(
                                color:
                                    _backupResult.contains('Error') ||
                                        _backupResult.contains('失败')
                                    ? Colors.red
                                    : (_backupResult.contains('成功')
                                          ? Colors.green
                                          : null),
                              ),
                            ),
                          if (_backupResult.isNotEmpty &&
                              _restoreResult.isNotEmpty)
                            SizedBox(height: 8),
                          if (_restoreResult.isNotEmpty)
                            Text(
                              _restoreResult,
                              style: TextStyle(
                                color:
                                    _restoreResult.contains('Error') ||
                                        _restoreResult.contains('失败')
                                    ? Colors.red
                                    : (_restoreResult.contains('成功')
                                          ? Colors.green
                                          : null),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
