import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';
import '../../utils/config_service.dart';

class LargeModelSettingsPage extends StatefulWidget {
  const LargeModelSettingsPage({super.key});

  @override
  State<LargeModelSettingsPage> createState() => _LargeModelSettingsPageState();
}

class _LargeModelSettingsPageState extends State<LargeModelSettingsPage> {
  Map<String, dynamic> _llmConfigs = {};
  Map<String, dynamic> _embeddingConfigs = {};

  @override
  void initState() {
    super.initState();
    // 初始化时加载配置
    _loadConfig();
  }

  /// 加载配置
  Future<void> _loadConfig() async {
    final config = ConfigService().getAll();
    if (config != null) {
      setState(() {
        _llmConfigs = Map<String, dynamic>.from(config['llm_configs'] ?? {});
        _embeddingConfigs = Map<String, dynamic>.from(
          config['embedding_configs'] ?? {},
        );
      });
    }
  }

  /// 保存配置
  Future<void> _saveConfig(
    String configType,
    String configName,
    Map<String, dynamic> configData,
  ) async {
    final key = '$configType.$configName';
    await ConfigService().set(key, configData);

    if (!mounted) return;

    final localizations = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.translate('config_saved')),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // 重新加载配置以反映更改
    _loadConfig();
  }

  /// 删除配置
  Future<void> _deleteConfig(String configType, String configName) async {
    final localizations = AppLocalizations.of(context);

    // 确认删除操作
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('confirm_delete')),
          content: Text(
            localizations.translateWithArgs('confirm_delete_message', [
              configName,
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.translate('cancel')),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(localizations.translate('delete')),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      // 从配置中删除
      final config = ConfigService().getAll();
      if (config != null && config[configType] != null) {
        final configs = Map<String, dynamic>.from(config[configType]);
        configs.remove(configName);
        await ConfigService().set(configType, configs);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.translateWithArgs('config_deleted', [configName]),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // 重新加载配置以反映更改
        _loadConfig();
      }
    }
  }

  /// 显示配置编辑对话框
  Future<void> _showConfigDialog(
      {String? configType, String? configName, Map<String, dynamic>? configData}) async {
    final localizations = AppLocalizations.of(context);

    // 控制器用于表单输入
    final nameController = TextEditingController(text: configName);
    final apiKeyController = TextEditingController(text: configData?['api_key'] ?? '');
    final baseUrlController = TextEditingController(text: configData?['base_url'] ?? '');
    final modelNameController = TextEditingController(text: configData?['model_name'] ?? '');
    final temperatureController =
        TextEditingController(text: (configData?['temperature'] ?? 0.7).toString());
    final maxTokensController =
        TextEditingController(text: (configData?['max_tokens'] ?? 8192).toString());
    final timeoutController =
        TextEditingController(text: (configData?['timeout'] ?? 600).toString());
    
    // 接口格式下拉框的当前值
    String selectedInterfaceFormat = configData?['interface_format'] ?? 'OpenAI';

    // 对于嵌入配置，还有一些额外的字段
    final retrievalKController =
        TextEditingController(text: (configData?['retrieval_k'] ?? 4).toString());

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(configName == null
                  ? localizations.translate('add_new_config')
                  : localizations.translateWithArgs('edit_config', [configName])),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('config_name'),
                      ),
                      enabled: configName == null, // 只有在添加新配置时才能编辑名称
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: apiKeyController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('api_key_label'),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: baseUrlController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('base_url'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: modelNameController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('model_name'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: temperatureController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('temperature'),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: maxTokensController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('max_tokens'),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: timeoutController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('timeout'),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    // 接口格式下拉框，目前仅有OpenAI选项
                    DropdownButtonFormField<String>(
                      initialValue: selectedInterfaceFormat,
                      decoration: InputDecoration(
                        labelText: localizations.translate('interface_format'),
                        border: const OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'OpenAI',
                          child: Text('OpenAI'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedInterfaceFormat = value;
                          });
                        }
                      },
                    ),
                    // 如果是嵌入配置，显示额外字段
                    if (configType == 'embedding_configs') ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: retrievalKController,
                        decoration: InputDecoration(
                          labelText: localizations.translate('retrieval_k'),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(localizations.translate('cancel')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(localizations.translate('save')),
                  onPressed: () async {
                    // 验证输入
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.translate('config_name_required'),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // 构建配置数据
                    final newConfigData = {
                      'api_key': apiKeyController.text,
                      'base_url': baseUrlController.text,
                      'model_name': modelNameController.text,
                      'temperature':
                          double.tryParse(temperatureController.text) ?? 0.7,
                      'max_tokens':
                          int.tryParse(maxTokensController.text) ?? 8192,
                      'timeout': int.tryParse(timeoutController.text) ?? 600,
                      'interface_format': selectedInterfaceFormat,
                    };

                    // 如果是嵌入配置，添加额外字段
                    if (configType == 'embedding_configs') {
                      newConfigData['retrieval_k'] =
                          int.tryParse(retrievalKController.text) ?? 4;
                    }

                    // 保存配置
                    await _saveConfig(configType!, nameController.text, newConfigData);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 构建配置列表项
  Widget _buildConfigListItem(
    String configType,
    String configName,
    Map<String, dynamic> configData,
  ) {
    final localizations = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    configName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showConfigDialog(
                        configType: configType,
                        configName: configName,
                        configData: configData,
                      ),
                      tooltip: localizations.translate('edit'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteConfig(configType, configName),
                      tooltip: localizations.translate('delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${localizations.translate('base_url')}: ${configData['base_url'] ?? ''}',
            ),
            Text(
              '${localizations.translate('model_name')}: ${configData['model_name'] ?? ''}',
            ),
            Text(
              '${localizations.translate('api_key_label')}: ${configData['api_key'] != null && configData['api_key'].toString().isNotEmpty ? '********' : localizations.translate('not_set')}',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LLM配置部分
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          localizations.translate('llm_configs'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () =>
                              _showConfigDialog(configType: 'llm_configs'),
                          tooltip: localizations.translate('add_new_config'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_llmConfigs.isEmpty)
                      Text(localizations.translate('no_llm_configs'))
                    else
                      ..._llmConfigs.entries.map(
                        (entry) => _buildConfigListItem(
                          'llm_configs',
                          entry.key,
                          entry.value,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 嵌入配置部分
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          localizations.translate('embedding_configs'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _showConfigDialog(
                            configType: 'embedding_configs',
                          ),
                          tooltip: localizations.translate('add_new_config'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_embeddingConfigs.isEmpty)
                      Text(localizations.translate('no_embedding_configs'))
                    else
                      ..._embeddingConfigs.entries.map(
                        (entry) => _buildConfigListItem(
                          'embedding_configs',
                          entry.key,
                          entry.value,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
