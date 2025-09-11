import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

/// 自定义日志格式化器，仿照Python logger风格
class SimpleLogPrinter extends LogPrinter {
  static const String _separator = ' | ';
  
  // 日志级别对应的文本
  static final Map<Level, String> _levelText = {
    Level.trace: 'TRACE',
    Level.debug: 'DEBUG',
    Level.info: 'INFO',
    Level.warning: 'WARNING',
    Level.error: 'ERROR',
    Level.fatal: 'FATAL',
  };
  
  @override
  List<String> log(LogEvent event) {
    // 格式: 时间戳 | 日志级别 | 消息
    final time = DateTime.now().toString().split('.').first;
    final levelText = _levelText[event.level] ?? 'UNKNOWN';
    final level = levelText.padRight(7);
    final message = event.message;
    
    return ['$time$_separator$level$_separator$message'];
  }
}

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  Logger? _logger;
  File? _logFile;
  IOSink? _logSink;
  bool _isInitialized = false;

  /// 初始化日志服务
  Future<void> init() async {
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

      // 创建自定义的日志输出，同时输出到控制台和文件
      _logger = Logger(
        printer: SimpleLogPrinter(),
        output: MultiOutput([
          ConsoleOutput(),
          FileOutput(file: _logFile!),
        ]),
      );

      _isInitialized = true;
      logInfo('Logger service initialized');
    } catch (e) {
      // 如果初始化失败，在开发环境中输出错误
      if (kDebugMode) {
        // 创建只输出到控制台的logger
        _logger = Logger(
          printer: SimpleLogPrinter(),
        );
      }
      _isInitialized = false;
    }
  }

  void logInfo(String message) {
    if (_logger != null) {
      _logger!.i(message);
    } else {
      // 在开发环境中输出到控制台
      if (kDebugMode) {
        // Fallback to debugPrint for development
        debugPrint('[INFO] $message');
      }
    }
  }

  void logError(String message) {
    if (_logger != null) {
      _logger!.e(message);
    } else {
      // 在开发环境中输出到控制台
      if (kDebugMode) {
        // Fallback to debugPrint for development
        debugPrint('[ERROR] $message');
      }
    }
  }

  void logWarning(String message) {
    if (_logger != null) {
      _logger!.w(message);
    } else {
      // 在开发环境中输出到控制台
      if (kDebugMode) {
        // Fallback to debugPrint for development
        debugPrint('[WARNING] $message');
      }
    }
  }

  void logDebug(String message) {
    if (_logger != null) {
      _logger!.d(message);
    } else {
      // 在开发环境中输出到控制台
      if (kDebugMode) {
        // Fallback to debugPrint for development
        debugPrint('[DEBUG] $message');
      }
    }
  }

  Future<void> close() async {
    try {
      await _logSink?.flush();
      await _logSink?.close();
    } catch (e) {
      // 在开发环境中输出到控制台
      if (kDebugMode) {
        debugPrint('Error closing log sink: $e');
      }
    } finally {
      _logSink = null;
      _logger = null;
      _isInitialized = false;
    }
  }

  String? get logFilePath => _logFile?.path;
  bool get isInitialized => _isInitialized;
}