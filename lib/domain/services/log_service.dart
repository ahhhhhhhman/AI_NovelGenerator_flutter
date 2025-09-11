import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  File? _logFile;
  IOSink? _logSink;

  /// 初始化日志服务，创建新的日志文件
  Future<void> init() async {
    print('>>> LogService.init() start');
    try {
      // 获取应用程序文档目录
      final appDocDir = await getApplicationDocumentsDirectory();
      // 创建应用特定的目录
      final appDir = Directory(path.join(appDocDir.path, 'novel_generator_flutter'));
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }
      
      final logDir = Directory(path.join(appDir.path, 'logs'));

      // 创建日志目录（如果不存在）
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // 使用时间戳创建唯一的日志文件名
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final logFilePath = path.join(logDir.path, 'app_$timestamp.log');

      _logFile = File(logFilePath);
      _logSink = _logFile!.openWrite(mode: FileMode.write);

      logInfo('Log service initialized');
    } catch (e) {
      print('Failed to initialize log service: $e');
    }
  }

  /* 以下代码与原来完全一致，无需改动 */
  void logInfo(String message) => _writeLog('INFO', message);
  void logError(String message) => _writeLog('ERROR', message);
  void logWarning(String message) => _writeLog('WARNING', message);

  void _writeLog(String level, String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] $level: $message\n';
    if (_logSink != null) {
      _logSink!.write(logEntry);
      _logSink!.flush();
    }
    if (bool.fromEnvironment('dart.vm.product') == false) {
      print(logEntry.trim());
    }
  }

  Future<void> close() async {
    await _logSink?.flush();
    await _logSink?.close();
    _logSink = null;
  }

  String? get logFilePath => _logFile?.path;
}
