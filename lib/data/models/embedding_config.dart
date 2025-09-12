class EmbeddingConfig {
  final String name;
  final String apiKey;
  final String baseUrl;
  final String modelName;
  final int retrievalK;
  final String interfaceFormat;

  EmbeddingConfig({
    required this.name,
    required this.apiKey,
    required this.baseUrl,
    required this.modelName,
    required this.retrievalK,
    required this.interfaceFormat,
  });

  factory EmbeddingConfig.fromJson(String name, Map<String, dynamic> json) {
    return EmbeddingConfig(
      name: name,
      apiKey: json['api_key'] as String? ?? '',
      baseUrl: json['base_url'] as String? ?? '',
      modelName: json['model_name'] as String? ?? '',
      retrievalK: json['retrieval_k'] as int? ?? 4,
      interfaceFormat: json['interface_format'] as String? ?? 'OpenAI',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'api_key': apiKey,
      'base_url': baseUrl,
      'model_name': modelName,
      'retrieval_k': retrievalK,
      'interface_format': interfaceFormat,
    };
  }
}