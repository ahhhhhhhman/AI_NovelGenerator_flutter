import '../services/llm_service.dart';
import '../services/logger_service.dart';

class LLMUseCase {
  final LLMService _llmService = LLMService();

  /// 测试LLM调用
  Future<String> generateText(String prompt, String configName) async {
    try {
      LoggerService().logInfo('Generating text with LLM: $configName');
      final result = await _llmService.callLLM(prompt, configName);
      LoggerService().logInfo('Successfully generated text with LLM: $configName');
      return result;
    } catch (e) {
      LoggerService().logError('Error generating text with LLM: $e');
      rethrow;
    }
  }
}