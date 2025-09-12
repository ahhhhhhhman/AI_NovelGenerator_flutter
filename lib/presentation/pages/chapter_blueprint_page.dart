import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/localizations/app_localizations.dart';
import '../../data/datasources/local/novel_file_service.dart';
import '../../domain/services/prompt_generator.dart';
import '../../domain/usecases/llm_usecase.dart';
import '../../utils/config_service.dart';
import '../pages/novel_architecture_page.dart';

class ChapterBlueprintPage extends StatefulWidget {
  const ChapterBlueprintPage({super.key});

  @override
  State<ChapterBlueprintPage> createState() => _ChapterBlueprintPageState();
}

class _ChapterBlueprintPageState extends State<ChapterBlueprintPage> {
  String? _selectedFolder;
  String? _directoryContent;
  bool _isLoading = false;
  bool _contentExists = false;
  bool _isSaving = false;
  bool _isGenerating = false;
  int _currentStep = 0;
  int _totalSteps = 0;
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
        _directoryContent != _textController.text) {
      _confirmSaveBeforeChange(() {
        setState(() {
          _selectedFolder = folderName;
          _directoryContent = null;
          _contentExists = false;
          _textController.text = '';
        });

        if (folderName != null) {
          _loadDirectoryContent(folderName);
        }
      });
    } else {
      setState(() {
        _selectedFolder = folderName;
        _directoryContent = null;
        _contentExists = false;
        _textController.text = '';
      });

      if (folderName != null) {
        _loadDirectoryContent(folderName);
      }
    }
  }

  // 加载章节蓝图内容
  Future<void> _loadDirectoryContent(String folderName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final content = await NovelFileService().readDirectory(folderName);
      setState(() {
        _directoryContent = content;
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
          _directoryContent != _textController.text) {
        _saveDirectoryContent(_selectedFolder!, _textController.text);
      }
    });
  }

  // 保存章节蓝图内容
  Future<void> _saveDirectoryContent(String folderName, String content) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final success = await NovelFileService().saveDirectory(
        folderName,
        content,
      );
      if (success) {
        setState(() {
          _directoryContent = content;
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
                  await _saveDirectoryContent(
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

  // 显示生成章节蓝图的对话框
  Future<void> _showGenerateBlueprintDialog() async {
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
    
    // 获取默认的章节蓝图LLM配置
    if (config != null && 
        config.containsKey('choose_configs') && 
        config['choose_configs'] is Map &&
        (config['choose_configs'] as Map).containsKey('chapter_outline_llm')) {
      defaultLlmConfig = config['choose_configs']['chapter_outline_llm'] as String;
    }
    
    // 控制器用于表单输入
    final guidanceController = TextEditingController(text: otherParams['user_guidance'] ?? '');
    
    // 当前选择的LLM配置
    String selectedLlmConfig = defaultLlmConfig;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(localizations.translate('generate_chapter_blueprint')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    // 保存用户指导到配置
                    await PromptGenerator().updateOtherParams({
                      'user_guidance': guidanceController.text,
                    });

                    // 关闭对话框
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    // 生成章节蓝图
                    await _generateChapterBlueprint(
                      guidanceController.text,
                      selectedLlmConfig,
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

  // 生成章节蓝图（每30章生成一次）
  Future<void> _generateChapterBlueprint(
    String userGuidance,
    String llmConfigName,
  ) async {
    if (_selectedFolder == null) return;

    setState(() {
      _isGenerating = true;
      _currentStep = 0;
    });

    final localizations = AppLocalizations.of(context);
    
    try {
      // 读取小说架构
      final novelArchitecture = await NovelFileService().readArchitecture(_selectedFolder!);
      if (novelArchitecture == null) {
        throw Exception('Novel architecture not found');
      }

      // 获取章节数
      final otherParams = PromptGenerator().getOtherParams();
      final totalChapters = otherParams['num_chapters'] as int? ?? 120;
      
      // 计算总步数（每30章为一步）
      _totalSteps = (totalChapters / 30).ceil();
      
      // 读取现有的章节蓝图内容
      String blueprintContent = _directoryContent ?? '';
      
      // 分批生成章节蓝图（每30章一批）
      for (int i = 0; i < _totalSteps; i++) {
        setState(() {
          _currentStep = i + 1;
        });
        
        final startChapter = i * 30 + 1;
        final endChapter = (i + 1) * 30;
        final actualEndChapter = endChapter > totalChapters ? totalChapters : endChapter;
        
        // 为了避免提示过长，只传入最近的章节信息
        String chapterListForPrompt = '';
        if (blueprintContent.isNotEmpty) {
          // 分割内容为行
          final lines = blueprintContent.split('\n');
          // 只保留最近的约100章信息（大约2000行，假设每章约20行）
          final maxLines = 2000;
          if (lines.length > maxLines) {
            chapterListForPrompt = lines.sublist(lines.length - maxLines).join('\n');
          } else {
            chapterListForPrompt = blueprintContent;
          }
        }
        
        // 生成章节蓝图提示
        final blueprintPrompt = PromptGenerator().generateChapterBlueprintPrompt(
          userGuidance: userGuidance,
          novelArchitecture: novelArchitecture,
          totalChapters: totalChapters,
          chapterList: chapterListForPrompt,
          startChapter: startChapter,
          endChapter: actualEndChapter,
        );

        // 调用LLM生成章节蓝图
        final llmUseCase = LLMUseCase();
        final generatedBlueprint = await llmUseCase.generateText(blueprintPrompt, llmConfigName);
        
        // 将生成的内容追加到现有内容
        if (blueprintContent.isNotEmpty && !blueprintContent.endsWith('\n')) {
          blueprintContent += '\n\n';
        }
        blueprintContent += generatedBlueprint;
        
        // 保存到文件
        await NovelFileService().saveDirectory(_selectedFolder!, blueprintContent);
      }

      // 完成
      setState(() {
        _directoryContent = blueprintContent;
        _contentExists = true;
        _textController.text = blueprintContent;
        _isGenerating = false;
        _currentStep = 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.translate('blueprint_generated')),
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
            content: Text('${localizations.translate('failed_to_generate_blueprint')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // 如果有未保存的更改，且文件已存在，则在页面销毁前保存
    // 注意：这里不能使用 _saveDirectoryContent，因为它会调用 setState，
    // 而 dispose 时 widget 已经被标记为 defunct。
    // 只有在文件已存在时才保存，避免创建新文件
    if (_selectedFolder != null &&
        _contentExists && // 添加对 _contentExists 的检查
        _directoryContent != _textController.text) {
      // 直接调用 service 保存，不更新 UI 状态
      NovelFileService().saveDirectory(_selectedFolder!, _textController.text);
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
                      Text(localizations.translateWithArgs('generating_step', [_currentStep.toString(), _totalSteps.toString()])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _totalSteps > 0 ? _currentStep / _totalSteps : 0),
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
            else if (!_contentExists && _directoryContent == null)
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
                      localizations.translate('chapter_blueprint_not_exists'),
                      style: const TextStyle(fontFamily: 'Microsoft YaHei'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showGenerateBlueprintDialog,
                    icon: const Icon(Icons.auto_fix_high),
                    label: Text(localizations.translate('generate_blueprint')),
                  ),
                ],
              )
            else
              // 文本编辑框
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 如果内容存在但不完整，显示生成按钮
                  if (_contentExists && _directoryContent != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _showGenerateBlueprintDialog,
                        icon: const Icon(Icons.auto_fix_high),
                        label: Text(localizations.translate('generate_blueprint')),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _textController,
                    maxLines: 20,
                    decoration: InputDecoration(
                      hintText: localizations.translate('chapter_blueprint_hint'),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    onChanged: (value) {
                      _scheduleSave();
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}