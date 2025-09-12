import 'dart:io';
import 'package:novel_generator_flutter/domain/usecases/llm_usecase.dart';
import 'package:novel_generator_flutter/utils/config_service.dart';
import 'package:novel_generator_flutter/domain/services/logger_service.dart';

/// 测试LLM功能的示例代码
Future<void> testLLMFunctionality() async {
  try {
    // 初始化配置服务
    await ConfigService().init();
    await LoggerService().init();
    
    LoggerService().logInfo('Starting LLM test');
    
    // 创建LLM使用案例
    final llmUseCase = LLMUseCase();
    
    // 获取配置中的第一个LLM配置名称
    final config = ConfigService().getAll();
    if (config != null && config.containsKey('llm_configs')) {
      final llmConfigs = config['llm_configs'] as Map;
      if (llmConfigs.isNotEmpty) {
        final configName = llmConfigs.keys.first;
        LoggerService().logInfo('Using LLM config: $configName');
        
        // 测试提示词
        const prompt = "写一个关于未来世界的小故事，长度约100字。";
        
        // 调用LLM
        final result = await llmUseCase.generateText(prompt, configName);
        LoggerService().logInfo('LLM Response: $result');
        
        // 在控制台输出结果
        if (LoggerService().isInitialized) {
          LoggerService().logInfo('LLM Response: $result');
        } else {
          // 如果日志服务未初始化，则使用debugPrint
          // ignore: avoid_print
          print('LLM Response: $result');
        }
      } else {
        LoggerService().logWarning('No LLM configurations found');
        // ignore: avoid_print
        print('No LLM configurations found');
      }
    } else {
      LoggerService().logWarning('LLM configurations not found in config');
      // ignore: avoid_print
      print('LLM configurations not found in config');
    }
  } catch (e) {
    LoggerService().logError('Error in LLM test: $e');
    // ignore: avoid_print
    print('Error in LLM test: $e');
  }
}

// 程序入口点示例
void main() async {
  await testLLMFunctionality();
  exit(0);
}