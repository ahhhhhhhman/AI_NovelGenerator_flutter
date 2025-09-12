import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../models/embedding_config.dart';
import '../../../domain/services/logger_service.dart';

class EmbeddingClient {
  static const int maxRetries = 3;
  static const int retryDelayMs = 1000;

  /// 生成嵌入向量
  Future<List<double>> generateEmbedding(String text, EmbeddingConfig config) async {
    LoggerService().logInfo('Generating embedding with model: ${config.modelName}');
    
    // 构建请求体
    final requestBody = {
      'model': config.modelName,
      'input': text,
    };

    // 发送请求并处理重试
    return _sendRequestWithRetry(config, requestBody);
  }

  /// 发送请求并处理重试逻辑
  Future<List<double>> _sendRequestWithRetry(EmbeddingConfig config, Map<String, dynamic> requestBody) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final response = await _sendRequest(config, requestBody);
        return response;
      } catch (e) {
        attempts++;
        LoggerService().logWarning('Embedding request failed (attempt $attempts): $e');
        
        if (attempts >= maxRetries) {
          LoggerService().logError('Embedding request failed after $maxRetries attempts: $e');
          rethrow;
        }
        
        // 等待后重试
        await Future.delayed(Duration(milliseconds: retryDelayMs * attempts));
      }
    }
    
    throw Exception('Failed to get embedding after $maxRetries attempts');
  }

  /// 发送HTTP请求到嵌入模型API
  Future<List<double>> _sendRequest(EmbeddingConfig config, Map<String, dynamic> requestBody) async {
    final url = '${config.baseUrl}/embeddings';
    LoggerService().logDebug('Sending embedding request to: $url');
    
    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${config.apiKey}',
        },
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: 300)); // 默认超时5分钟

      LoggerService().logDebug('Embedding response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final embedding = (jsonResponse['data'][0]['embedding'] as List)
            .map((e) => (e as num).toDouble())
            .toList();
        LoggerService().logInfo('Successfully received embedding, dimension: ${embedding.length}');
        return embedding;
      } else {
        LoggerService().logError('Embedding API error: ${response.statusCode} - ${response.body}');
        throw Exception('Embedding API error: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException catch (e) {
      LoggerService().logError('Embedding request timeout: $e');
      throw Exception('Embedding request timeout: $e');
    } on SocketException catch (e) {
      LoggerService().logError('Network error: $e');
      throw Exception('Network error: $e');
    } catch (e) {
      LoggerService().logError('Unexpected error: $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}