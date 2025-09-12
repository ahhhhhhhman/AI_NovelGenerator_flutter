import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/localizations/app_localizations.dart';
import '../../data/datasources/local/novel_file_service.dart';
import '../../domain/services/prompt_generator.dart';
import '../../domain/usecases/llm_usecase.dart';
import '../../utils/config_service.dart';

// 创建一个状态管理类来存储当前选择的小说
class SelectedNovelProvider with ChangeNotifier {
  String? _selectedNovel;

  String? get selectedNovel => _selectedNovel;

  void setSelectedNovel(String? novel) {
    _selectedNovel = novel;
    notifyListeners();
  }
}

class NovelArchitecturePage extends StatefulWidget {
  const NovelArchitecturePage({super.key});

  @override
  State<NovelArchitecturePage> createState() => _NovelArchitecturePageState();
}

class _NovelArchitecturePageState extends State<NovelArchitecturePage> {
  String? _selectedFolder;
  String? _architectureContent;
  bool _isLoading = false;
  bool _contentExists = false;
  bool _isSaving = false;
  bool _isGenerating = false;
  int _currentStep = 0; // 当前生成步骤
  Timer? _saveTimer;  
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化时监听选择状态的变化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialSelection();
    });
  }

  void _checkInitialSelection() {
    final selectedNovel = context.read<SelectedNovelProvider>().selectedNovel;
    if (selectedNovel != _selectedFolder) {
      _onNovelSelected(selectedNovel);
    }
  }

  // 处理小说选择变化
  void _onNovelSelected(String? folderName) {
    // 如果文件已存在且有未保存的更改，提示用户
    if (_selectedFolder != null &&
        _contentExists && // 添加对 _contentExists 的检查
        _architectureContent != _textController.text) {
      _confirmSaveBeforeChange(() {
        setState(() {
          _selectedFolder = folderName;
          _architectureContent = null;
          _contentExists = false;
          _textController.text = '';
        });

        if (folderName != null) {
          _loadArchitectureContent(folderName);
        }
      });
    } else {
      setState(() {
        _selectedFolder = folderName;
        _architectureContent = null;
        _contentExists = false;
        _textController.text = '';
      });

      if (folderName != null) {
        _loadArchitectureContent(folderName);
      }
    }
  }

  // 加载小说架构内容
  Future<void> _loadArchitectureContent(String folderName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final content = await NovelFileService().readArchitecture(folderName);
      setState(() {
        _architectureContent = content;
        _contentExists = content != null;
        _textController.text = content ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _contentExists = false;
        _textController.text = '';
      });
    }
  }

  // 延迟保存内容
  void _scheduleSave() {
    // 取消之前的定时器
    _saveTimer?.cancel();

    // 设置新的定时器，在2秒后保存
    _saveTimer = Timer(const Duration(seconds: 2), () {
      if (_selectedFolder != null &&
          _architectureContent != _textController.text) {
        _saveArchitectureContent(_selectedFolder!, _textController.text);
      }
    });
  }

  // 保存小说架构内容
  Future<void> _saveArchitectureContent(
    String folderName,
    String content,
  ) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final success = await NovelFileService().saveArchitecture(
        folderName,
        content,
      );
      if (success) {
        setState(() {
          _architectureContent = content;
          _contentExists = true;
          _isSaving = false;
        });

        // 显示保存成功的提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).translate('save_successful'),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _isSaving = false;
        });

        // 显示保存失败的提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).translate('save_failed'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      // 显示保存失败的提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('save_failed'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 确认保存更改
  void _confirmSaveBeforeChange(VoidCallback onConfirmed) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('unsaved_changes')),
          content: Text(localizations.translate('unsaved_changes_message')),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.translate('cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(localizations.translate('discard')),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirmed();
              },
            ),
            TextButton(
              child: Text(localizations.translate('save')),
              onPressed: () async {
                Navigator.of(context).pop();
                if (_selectedFolder != null) {
                  await _saveArchitectureContent(
                    _selectedFolder!,
                    _textController.text,
                  );
                  onConfirmed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // 显示生成小说架构的对话框
  Future<void> _showGenerateArchitectureDialog() async {
    if (_selectedFolder == null) return;

    final localizations = AppLocalizations.of(context);
    
    // 获取当前配置参数
    final otherParams = PromptGenerator().getOtherParams();
    
    // 获取LLM配置选项
    final config = ConfigService().getAll();
    List<String> llmConfigOptions = [];
    String defaultLlmConfig = 'DeepSeek V3'; // 默认配置
    
    if (config != null && 
        config.containsKey('llm_configs') && 
        config['llm_configs'] is Map) {
      llmConfigOptions = (config['llm_configs'] as Map).keys.cast<String>().toList();
    }
    
    // 获取默认的小说架构LLM配置
    if (config != null && 
        config.containsKey('choose_configs') && 
        config['choose_configs'] is Map &&
        (config['choose_configs'] as Map).containsKey('architecture_llm')) {
      defaultLlmConfig = config['choose_configs']['architecture_llm'] as String;
    }
    
    // 控制器用于表单输入
    final topicController = TextEditingController(text: otherParams['topic'] ?? '');
    final genreController = TextEditingController(text: otherParams['genre'] ?? '');
    final chaptersController = TextEditingController(text: (otherParams['num_chapters'] ?? 0).toString());
    final wordsController = TextEditingController(text: (otherParams['word_number'] ?? 0).toString());
    final guidanceController = TextEditingController(text: otherParams['user_guidance'] ?? '');
    
    // 当前选择的LLM配置
    String selectedLlmConfig = defaultLlmConfig;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(localizations.translate('generate_novel_architecture')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: topicController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('topic'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: genreController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('genre'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: chaptersController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('number_of_chapters'),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: wordsController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('words_per_chapter'),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: guidanceController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('user_guidance'),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // LLM配置选择下拉框
                    DropdownButtonFormField<String>(
                      initialValue: selectedLlmConfig,
                      decoration: InputDecoration(
                        labelText: localizations.translate('select_llm_config'),
                        border: const OutlineInputBorder(),
                      ),
                      items: llmConfigOptions.map((String configName) {
                        return DropdownMenuItem<String>(
                          value: configName,
                          child: Text(configName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedLlmConfig = value;
                          });
                        }
                      },
                    ),
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
                  child: Text(localizations.translate('generate')),
                  onPressed: () async {
                    // 验证输入
                    if (topicController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.translate('topic_required'),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final numChapters = int.tryParse(chaptersController.text) ?? 0;
                    final wordNumber = int.tryParse(wordsController.text) ?? 0;

                    if (numChapters <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.translate('chapters_must_be_positive'),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (wordNumber <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizations.translate('words_must_be_positive'),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // 保存参数到配置
                    await PromptGenerator().updateOtherParams({
                      'topic': topicController.text,
                      'genre': genreController.text,
                      'num_chapters': numChapters,
                      'word_number': wordNumber,
                      'user_guidance': guidanceController.text,
                    });

                    // 关闭对话框
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    // 生成小说架构
                    await _generateFullArchitecture(
                      topicController.text,
                      genreController.text,
                      numChapters,
                      wordNumber,
                      guidanceController.text,
                      selectedLlmConfig, // 传递选择的LLM配置
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 生成完整的小说架构（四步流程）
  Future<void> _generateFullArchitecture(
    String topic,
    String genre,
    int numberOfChapters,
    int wordNumber,
    String userGuidance,
    String llmConfigName, // 添加LLM配置参数
  ) async {
    if (_selectedFolder == null) return;

    setState(() {
      _isGenerating = true;
      _currentStep = 0;
    });

    final localizations = AppLocalizations.of(context);
    
    try {
      // 步骤1: 生成核心种子
      setState(() {
        _currentStep = 1;
      });
      
      // 首先保存小说设定信息
      String architectureContent = '=== 小说设定 ===\n主题：$topic\n类型：$genre\n篇幅：约$numberOfChapters章（每章$wordNumber字）\n\n';
      await NovelFileService().saveArchitecture(_selectedFolder!, architectureContent);
      
      final coreSeedPrompt = PromptGenerator().generateCoreSeedPrompt(
        topic: topic,
        genre: genre,
        numberOfChapters: numberOfChapters,
        wordNumber: wordNumber,
        userGuidance: userGuidance,
      );

      // 调用LLM生成核心种子
      final llmUseCase = LLMUseCase();
      final coreSeed = await llmUseCase.generateText(coreSeedPrompt, llmConfigName);
      
      // 保存核心种子到架构文件
      architectureContent += '=== 核心种子 ===\n$coreSeed\n\n';
      await NovelFileService().saveArchitecture(_selectedFolder!, architectureContent);

      // 步骤2: 生成角色动力学
      setState(() {
        _currentStep = 2;
      });
      
      final characterDynamicsPrompt = PromptGenerator().generateCharacterDynamicsPrompt(
        userGuidance: userGuidance,
        coreSeed: coreSeed,
      );
      
      final characterDynamics = await llmUseCase.generateText(characterDynamicsPrompt, llmConfigName);
      architectureContent += '=== 角色动力学 ===\n$characterDynamics\n\n';
      await NovelFileService().saveArchitecture(_selectedFolder!, architectureContent);

      // 步骤2.5: 生成角色状态并保存到character_state.txt
      final characterStatePrompt = PromptGenerator().generateCharacterStatePrompt(
        characterDynamics: characterDynamics,
      );
      
      final characterState = await llmUseCase.generateText(characterStatePrompt, llmConfigName);
      await NovelFileService().saveCharacterState(_selectedFolder!, characterState);

      // 步骤3: 生成世界构建
      setState(() {
        _currentStep = 3;
      });
      
      final worldBuildingPrompt = PromptGenerator().generateWorldBuildingPrompt(
        userGuidance: userGuidance,
        coreSeed: coreSeed,
      );
      
      final worldBuilding = await llmUseCase.generateText(worldBuildingPrompt, llmConfigName);
      architectureContent += '=== 世界构建 ===\n$worldBuilding\n\n';
      await NovelFileService().saveArchitecture(_selectedFolder!, architectureContent);

      // 步骤4: 生成情节架构
      setState(() {
        _currentStep = 4;
      });
      
      final plotArchitecturePrompt = PromptGenerator().generatePlotArchitecturePrompt(
        userGuidance: userGuidance,
        coreSeed: coreSeed,
        characterDynamics: characterDynamics,
        worldBuilding: worldBuilding,
      );
      
      final plotArchitecture = await llmUseCase.generateText(plotArchitecturePrompt, llmConfigName);
      architectureContent += '=== 情节架构 ===\n$plotArchitecture\n\n';
      await NovelFileService().saveArchitecture(_selectedFolder!, architectureContent);

      // 完成
      setState(() {
        _architectureContent = architectureContent;
        _contentExists = true;
        _textController.text = architectureContent;
        _isGenerating = false;
        _currentStep = 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.translate('architecture_generated')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _currentStep = 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations.translate('failed_to_generate_architecture')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // 如果有未保存的更改，且文件已存在，则在页面销毁前保存
    // 注意：这里不能使用 _saveArchitectureContent，因为它会调用 setState，
    // 而 dispose 时 widget 已经被标记为 defunct。
    // 只有在文件已存在时才保存，避免创建新文件
    if (_selectedFolder != null &&
        _contentExists && // 添加对 _contentExists 的检查
        _architectureContent != _textController.text) {
      // 直接调用 service 保存，不更新 UI 状态
      NovelFileService().saveArchitecture(_selectedFolder!, _textController.text);
    }

    // 清除定时器
    _saveTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 监听选择状态的变化
    final selectedNovel = context.watch<SelectedNovelProvider>().selectedNovel;

    // 如果选择状态发生变化，更新页面
    // 使用 addPostFrameCallback 确保在 build 完成后才执行
    if (selectedNovel != _selectedFolder) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _onNovelSelected(selectedNovel);
        }
      });
    }

    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 保存状态指示器
            if (_isSaving)
              Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 8),
                  Text(localizations.translate('saving')),
                ],
              ),
            if (_isSaving) const SizedBox(height: 8),
            
            // 生成状态指示器
            if (_isGenerating)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 8),
                      Text(localizations.translateWithArgs('generating_step', [_currentStep.toString(), '4'])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _currentStep / 4),
                  const SizedBox(height: 8),
                ],
              ),

            // 文本编辑区域
            if (_selectedFolder == null)
              // 未选择小说时显示提示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  localizations.translate('select_novel_first'),
                  style: const TextStyle(fontFamily: 'Microsoft YaHei'),
                ),
              )
            else if (_isLoading)
              // 加载中显示进度指示器
              const Center(child: CircularProgressIndicator())
            else if (!_contentExists && _architectureContent == null)
              // 文件不存在时显示提示和生成按钮
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      localizations.translate('novel_architecture_not_exists'),
                      style: const TextStyle(fontFamily: 'Microsoft YaHei'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showGenerateArchitectureDialog,
                    icon: const Icon(Icons.auto_fix_high),
                    label: Text(localizations.translate('generate_architecture')),
                  ),
                ],
              )
            else
              // 文本编辑框
              TextField(
                controller: _textController,
                maxLines: 20,
                decoration: InputDecoration(
                  hintText: localizations.translate('novel_architecture_hint'),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (value) {
                  _scheduleSave();
                },
              ),
          ],
        ),
      ),
    );
  }
}