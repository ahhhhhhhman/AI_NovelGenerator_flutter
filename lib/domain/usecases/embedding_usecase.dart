import '../services/embedding_service.dart';
import '../services/logger_service.dart';

class EmbeddingUseCase {
  final EmbeddingService _embeddingService = EmbeddingService();

  /// 生成嵌入向量
  Future<List<double>> generateEmbedding(String text, String configName) async {
    try {
      LoggerService().logInfo('Generating embedding with config: $configName');
      final result = await _embeddingService.generateEmbedding(text, configName);
      LoggerService().logInfo('Successfully generated embedding with config: $configName');
      return result;
    } catch (e) {
      LoggerService().logError('Error generating embedding with config: $e');
      rethrow;
    }
  }
}