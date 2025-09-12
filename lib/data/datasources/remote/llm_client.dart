import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../models/llm_config.dart';
import '../../../domain/services/logger_service.dart';

class LLMClient {
  static const int maxRetries = 3;
  static const int retryDelayMs = 1000;

  /// 调用LLM API
  Future<String> callLLM(String prompt, LLMConfig config) async {
    LoggerService().logInfo('Calling LLM: ${config.name} with model: ${config.modelName}');
    
    // 构建请求体
    final requestBody = {
      'model': config.modelName,
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'temperature': config.temperature,
      'max_tokens': config.maxTokens,
    };

    // 发送请求并处理重试
    return _sendRequestWithRetry(config, requestBody);
  }

  /// 发送请求并处理重试逻辑
  Future<String> _sendRequestWithRetry(LLMConfig config, Map<String, dynamic> requestBody) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final response = await _sendRequest(config, requestBody);
        return response;
      } catch (e) {
        attempts++;
        LoggerService().logWarning('LLM request failed (attempt $attempts): $e');
        
        if (attempts >= maxRetries) {
          LoggerService().logError('LLM request failed after $maxRetries attempts: $e');
          rethrow;
        }
        
        // 等待后重试
        await Future.delayed(Duration(milliseconds: retryDelayMs * attempts));
      }
    }
    
    throw Exception('Failed to get response from LLM after $maxRetries attempts');
  }

  /// 发送HTTP请求到LLM API
  Future<String> _sendRequest(LLMConfig config, Map<String, dynamic> requestBody) async {
    final url = '${config.baseUrl}/chat/completions';
    LoggerService().logDebug('Sending request to: $url');
    
    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${config.apiKey}',
        },
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: config.timeout));

      LoggerService().logDebug('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'];
        LoggerService().logInfo('Successfully received response from LLM');
        return content;
      } else {
        LoggerService().logError('LLM API error: ${response.statusCode} - ${response.body}');
        throw Exception('LLM API error: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException catch (e) {
      LoggerService().logError('Request timeout: $e');
      throw Exception('Request timeout: $e');
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