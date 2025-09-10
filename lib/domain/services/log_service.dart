import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  File? _logFile;
  IOSink? _logSink;

  /// 初始化日志服务，创建新的日志文件
  Future<void> init() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final logDir = Directory(path.join(appDocDir.path, 'logs'));

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
      // 如果无法创建日志文件，回退到控制台输出
      // 这里是初始化日志服务失败的情况，所以我们直接使用print
      print('Failed to initialize log service: $e');
    }
  }

  /// 记录信息日志
  void logInfo(String message) {
    _writeLog('INFO', message);
  }

  /// 记录错误日志
  void logError(String message) {
    _writeLog('ERROR', message);
  }

  /// 记录警告日志
  void logWarning(String message) {
    _writeLog('WARNING', message);
  }

  /// 写入日志到文件
  void _writeLog(String level, String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] $level: $message\\n';
    // 写入文件（如果可用）
    if (_logSink != null) {
      _logSink!.write(logEntry);
      _logSink!.flush(); // 确保立即写入
    }

    // 同时输出到控制台（仅在调试模式下）
    if (bool.fromEnvironment('dart.vm.product') == false) {
      // 这里保持print语句，因为我们就是在实现日志功能
      print(logEntry.trim());
    }
  }

  /// 关闭日志服务
  Future<void> close() async {
    await _logSink?.flush();
    await _logSink?.close();
    _logSink = null;
  }

  /// 获取日志文件路径
  String? get logFilePath => _logFile?.path;
}
