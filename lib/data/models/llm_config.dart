class LLMConfig {
  final String name;
  final String apiKey;
  final String baseUrl;
  final String modelName;
  final double temperature;
  final int maxTokens;
  final int timeout;
  final String interfaceFormat;

  LLMConfig({
    required this.name,
    required this.apiKey,
    required this.baseUrl,
    required this.modelName,
    required this.temperature,
    required this.maxTokens,
    required this.timeout,
    required this.interfaceFormat,
  });

  factory LLMConfig.fromJson(String name, Map<String, dynamic> json) {
    return LLMConfig(
      name: name,
      apiKey: json['api_key'] as String? ?? '',
      baseUrl: json['base_url'] as String? ?? '',
      modelName: json['model_name'] as String? ?? '',
      temperature: (json['temperature'] as num? ?? 0.7).toDouble(),
      maxTokens: json['max_tokens'] as int? ?? 2048,
      timeout: json['timeout'] as int? ?? 300,
      interfaceFormat: json['interface_format'] as String? ?? 'OpenAI',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'api_key': apiKey,
      'base_url': baseUrl,
      'model_name': modelName,
      'temperature': temperature,
      'max_tokens': maxTokens,
      'timeout': timeout,
      'interface_format': interfaceFormat,
    };
  }
}