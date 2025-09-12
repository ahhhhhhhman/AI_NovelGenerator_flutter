import '../../data/models/embedding_config.dart';
import '../../data/datasources/remote/embedding_client.dart';
import '../../utils/config_service.dart';
import '../services/logger_service.dart';

class EmbeddingService {
  static final EmbeddingService _instance = EmbeddingService._internal();
  factory EmbeddingService() => _instance;
  EmbeddingService._internal();

  final EmbeddingClient _client = EmbeddingClient();

  /// 根据配置名称获取嵌入模型配置
  EmbeddingConfig? _getEmbeddingConfig(String configName) {
    try {
      final config = ConfigService().getAll();
      if (config != null && 
          config.containsKey('embedding_configs') && 
          config['embedding_configs'] is Map &&
          (config['embedding_configs'] as Map).containsKey(configName)) {
        
        final embeddingConfig = (config['embedding_configs'] as Map)[configName];
        if (embeddingConfig is Map<String, dynamic>) {
          return EmbeddingConfig.fromJson(configName, embeddingConfig);
        }
      }
      LoggerService().logWarning('Embedding config not found for: $configName');
      return null;
    } catch (e) {
      LoggerService().logError('Error getting embedding config for $configName: $e');
      return null;
    }
  }

  /// 生成嵌入向量
  Future<List<double>> generateEmbedding(String text, String configName) async {
    LoggerService().logInfo('Generating embedding with config: $configName');
    
    final config = _getEmbeddingConfig(configName);
    if (config == null) {
      throw Exception('Embedding configuration not found for: $configName');
    }

    if (config.apiKey.isEmpty) {
      throw Exception('API key is required for embedding configuration: $configName');
    }

    if (config.baseUrl.isEmpty) {
      throw Exception('Base URL is required for embedding configuration: $configName');
    }

    return await _client.generateEmbedding(text, config);
  }
}