import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/localizations/app_localizations.dart';
import '../../data/datasources/local/novel_file_service.dart';
import '../../utils/config_service.dart';
import '../../domain/services/llm_service.dart'; // 导入 LLMService
import '../../domain/services/logger_service.dart'; // 导入 LoggerService
import '../pages/novel_architecture_page.dart'; // 导入 SelectedNovelProvider
import '../../domain/services/prompt_generator.dart'; // 导入 PromptGenerator

class MainFeaturesPage extends StatefulWidget {
  const MainFeaturesPage({super.key});

  @override
  State<MainFeaturesPage> createState() => _MainFeaturesPageState();
}

class _MainFeaturesPageState extends State<MainFeaturesPage> {
  // 控制器用于表单输入
  final TextEditingController _chapterNumberController =
      TextEditingController();
  final TextEditingController _wordCountController = TextEditingController();
  final TextEditingController _contentGuidanceController =
      TextEditingController();
  final TextEditingController _coreCharactersController =
      TextEditingController();
  final TextEditingController _keyItemsController = TextEditingController();
  final TextEditingController _timePressureController = TextEditingController();
  final TextEditingController _spatialCoordinatesController =
      TextEditingController();

  @override
  void dispose() {
    _chapterNumberController.dispose();
    _wordCountController.dispose();
    _contentGuidanceController.dispose();
    _coreCharactersController.dispose();
    _keyItemsController.dispose();
    _timePressureController.dispose();
    _spatialCoordinatesController.dispose();
    super.dispose();
  }

  /// 获取最大章节号并设置到输入框
  Future<void> _setNextChapterNumber(String novelFolderName) async {
    try {
      final chapterNumbers = await NovelFileService().getChapterNumbers(
        novelFolderName,
      );
      int nextChapterNumber = 1;

      if (chapterNumbers.isNotEmpty) {
        nextChapterNumber = chapterNumbers.last + 1;
      }

      if (mounted) {
        setState(() {
          _chapterNumberController.text = nextChapterNumber.toString();
        });
      }
    } catch (e) {
      // 如果出错，默认设置为1
      if (mounted) {
        setState(() {
          _chapterNumberController.text = '1';
        });
      }
    }
  }

  /// 从 Novel_directory.txt 中解析章节信息
  Future<Map<String, String>?> _parseChapterInfoFromDirectory(
      String novelFolderName, int chapterNumber) async {
    try {
      final directoryContent =
          await NovelFileService().readDirectory(novelFolderName);
      if (directoryContent == null || directoryContent.isEmpty) {
        return null;
      }

      // 解析 Novel_directory.txt 的内容
      // 假设格式为:
      // 第n章 - [标题]
      // 本章定位：[角色/事件/主题/...]
      // 核心作用：[推进/转折/揭示/...]
      // 悬念密度：[紧凑/渐进/爆发/...]
      // 伏笔操作：埋设(A线索)→强化(B矛盾)...
      // 认知颠覆：★☆☆☆☆
      // 本章简述：[一句话概括]
      //
      final lines = LineSplitter().convert(directoryContent);
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.startsWith('第$chapterNumber章 - ')) {
          final info = <String, String>{};
          
          // 提取标题
          info['title'] = line.substring('第$chapterNumber章 - '.length);
          
          // 继续解析后续行，直到遇到下一个章节或文件结尾
          for (int j = i + 1; j < lines.length; j++) {
            final nextLine = lines[j].trim();
            // 如果遇到下一个章节标题，则停止解析
            if (nextLine.startsWith('第') && nextLine.contains('章 - ')) {
              break;
            }
            
            // 解析各个字段
            if (nextLine.startsWith('本章定位：')) {
              info['role'] = nextLine.substring('本章定位：'.length);
            } else if (nextLine.startsWith('核心作用：')) {
              info['purpose'] = nextLine.substring('核心作用：'.length);
            } else if (nextLine.startsWith('悬念密度：')) {
              info['suspense_level'] = nextLine.substring('悬念密度：'.length);
            } else if (nextLine.startsWith('伏笔操作：')) {
              info['foreshadowing'] = nextLine.substring('伏笔操作：'.length);
            } else if (nextLine.startsWith('认知颠覆：')) {
              info['plot_twist_level'] = nextLine.substring('认知颠覆：'.length);
            } else if (nextLine.startsWith('本章简述：')) {
              info['summary'] = nextLine.substring('本章简述：'.length);
            }
          }
          
          return info;
        }
      }
      return null;
    } catch (e) {
      // 如果解析失败，返回null
      return null;
    }
  }

  /// 显示生成章节对话框
  Future<void> _showGenerateChapterDialog(String novelFolderName) async {
    // 初始化章节号为最大章节号+1
    await _setNextChapterNumber(novelFolderName);

    // 检查State是否仍然挂载
    if (!mounted) return;
    
    // 获取可用的LLM配置列表
    List<String> llmConfigNames = ['默认配置']; // 默认值，防止空列表
    String? defaultLLMConfigName;
    try {
      final config = ConfigService().getAll();
      if (config != null && 
          config.containsKey('llm_configs') && 
          config['llm_configs'] is Map) {
        final keys = (config['llm_configs'] as Map).keys.toList();
        if (keys.isNotEmpty) {
          llmConfigNames = keys.cast<String>(); // 确保类型正确
        }
      }
      // 获取默认配置（如果有）
      if (config != null && 
          config.containsKey('choose_configs') && 
          config['choose_configs'] is Map &&
          (config['choose_configs'] as Map).containsKey('prompt_draft_llm')) {
        defaultLLMConfigName = (config['choose_configs'] as Map)['prompt_draft_llm'] as String?;
      }
    } catch (e) {
      // 如果获取配置失败，使用默认列表
    }
    
    // 默认选中的配置
    String selectedLLMConfig = defaultLLMConfigName ?? (llmConfigNames.isNotEmpty ? llmConfigNames.first : '默认配置');

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogLocalizations = AppLocalizations.of(dialogContext);
        final dialogNavigator = Navigator.of(dialogContext);
        final dialogScaffoldMessenger = ScaffoldMessenger.of(dialogContext);

        return AlertDialog(
          title: Text(dialogLocalizations.translate('generate_chapter')),
          content: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 60,
                    child: TextField(
                      controller: _chapterNumberController,
                      decoration: InputDecoration(
                        labelText: dialogLocalizations.translate(
                          'chapter_number',
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 60,
                    child: TextField(
                      controller: _wordCountController,
                      decoration: InputDecoration(
                        labelText: dialogLocalizations.translate(
                          'expected_word_count',
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 60,
                    child: TextField(
                      controller: _contentGuidanceController,
                      decoration: InputDecoration(
                        labelText: dialogLocalizations.translate(
                          'content_guidance',
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 60,
                    child: TextField(
                      controller: _coreCharactersController,
                      decoration: InputDecoration(
                        labelText: dialogLocalizations.translate(
                          'core_characters',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 60,
                    child: TextField(
                      controller: _keyItemsController,
                      decoration: InputDecoration(
                        labelText: dialogLocalizations.translate('key_items'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 60,
                    child: TextField(
                      controller: _timePressureController,
                      decoration: InputDecoration(
                        labelText: dialogLocalizations.translate('time_pressure'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 60,
                    child: TextField(
                      controller: _spatialCoordinatesController,
                      decoration: InputDecoration(
                        labelText: dialogLocalizations.translate(
                          'spatial_coordinates',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 添加LLM配置选择下拉框
                  DropdownButtonFormField<String>(
                    initialValue: selectedLLMConfig,
                    items: llmConfigNames.map<DropdownMenuItem<String>>((String name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // 更新选中的LLM配置
                        selectedLLMConfig = newValue;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: dialogLocalizations.translate('select_llm_config'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(dialogLocalizations.translate('cancel')),
              onPressed: () {
                dialogNavigator.pop();
              },
            ),
            TextButton(
              child: Text(dialogLocalizations.translate('generate')),
              onPressed: () async {
                // 验证输入
                if (_chapterNumberController.text.trim().isEmpty) {
                  dialogScaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        dialogLocalizations.translate(
                          'chapter_number_required',
                        ),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final chapterNumber = int.tryParse(
                  _chapterNumberController.text,
                );
                if (chapterNumber == null || chapterNumber <= 0) {
                  dialogScaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        dialogLocalizations.translate(
                          'chapter_number_must_be_positive',
                        ),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final wordCount = int.tryParse(_wordCountController.text) ?? 0;
                if (wordCount <= 0) {
                  dialogScaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        dialogLocalizations.translate(
                          'word_count_must_be_positive',
                        ),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // 关闭对话框
                dialogNavigator.pop();

                // 实现生成章节的逻辑
                if (chapterNumber == 1) {
                  // 获取第一章信息
                  final chapterInfo = await _parseChapterInfoFromDirectory(novelFolderName, chapterNumber);
                  final chapterTitle = chapterInfo?['title'] ?? '第一章标题';
                  final chapterRole = chapterInfo?['role'] ?? '开篇';
                  final chapterPurpose = chapterInfo?['purpose'] ?? '引入故事背景和主要角色';
                  final suspenseLevel = chapterInfo?['suspense_level'] ?? '渐进';
                  final foreshadowing = chapterInfo?['foreshadowing'] ?? '埋设主要线索A';
                  final plotTwistLevel = chapterInfo?['plot_twist_level'] ?? '★☆☆☆☆';
                  final chapterSummary = chapterInfo?['summary'] ?? '简要描述第一章的内容';
                  
                  // 如果是第一章，使用特定的提示词并弹出编辑框
                  final promptGenerator = PromptGenerator();
                  // 读取小说架构内容
                  final novelArchitectureText = await NovelFileService().readArchitecture(novelFolderName) ?? '这里应该是完整的小说架构文本';
                  final prompt = promptGenerator
                      .generateFirstChapterDraftPrompt(
                        novelNumber: chapterNumber,
                        chapterTitle: chapterTitle,
                        chapterRole: chapterRole,
                        chapterPurpose: chapterPurpose,
                        suspenseLevel: suspenseLevel,
                        foreshadowing: foreshadowing,
                        plotTwistLevel: plotTwistLevel,
                        chapterSummary: chapterSummary,
                        charactersInvolved: _coreCharactersController.text,
                        keyItems: _keyItemsController.text,
                        sceneLocation: _spatialCoordinatesController.text,
                        timeConstraint: _timePressureController.text,
                        novelArchitectureText: novelArchitectureText,
                        wordNumber: wordCount,
                        userGuidance: _contentGuidanceController.text,
                      );

                  // 弹出编辑框让用户编辑提示词
                  _showEditPromptDialog(prompt, (editedPrompt) {
                    // 后续逻辑暂时占位
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            ).translate('first_chapter_prompt_edited'),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  });
                } else {
                  // 对于非第一章，需要获取更多上下文信息并生成提示词
                  // 获取 global_summary.txt 内容
                  final globalSummary = await NovelFileService().readGlobalSummary(novelFolderName) ?? '';
                  
                  // 获取上一章的最后800字
                  String previousChapterExcerpt = '';
                  try {
                    final previousChapterNumber = chapterNumber - 1;
                    final previousChapterContent = await NovelFileService().readChapter(novelFolderName, previousChapterNumber);
                    if (previousChapterContent != null && previousChapterContent.isNotEmpty) {
                      // 获取最后800字符
                      final start = previousChapterContent.length > 800 ? previousChapterContent.length - 800 : 0;
                      previousChapterExcerpt = previousChapterContent.substring(start);
                    }
                  } catch (e) {
                    // 如果无法读取上一章内容，保持为空
                  }
                  
                  // 获取 character_state.txt 内容
                  final characterState = await NovelFileService().readCharacterState(novelFolderName) ?? '';
                  
                  // 获取当前章节信息
                  final chapterInfo = await _parseChapterInfoFromDirectory(novelFolderName, chapterNumber);
                  final chapterTitle = chapterInfo?['title'] ?? '第$chapterNumber章标题';
                  final chapterRole = chapterInfo?['role'] ?? '发展中段';
                  final chapterPurpose = chapterInfo?['purpose'] ?? '推进主线剧情';
                  final suspenseLevel = chapterInfo?['suspense_level'] ?? '渐进';
                  final foreshadowing = chapterInfo?['foreshadowing'] ?? '强化线索B';
                  final plotTwistLevel = chapterInfo?['plot_twist_level'] ?? '★☆☆☆☆';
                  final chapterSummary = chapterInfo?['summary'] ?? '简要描述第$chapterNumber章的内容';
                  
                  // 获取下一章节信息
                  final nextChapterInfo = await _parseChapterInfoFromDirectory(novelFolderName, chapterNumber + 1);
                  final nextChapterTitle = nextChapterInfo?['title'] ?? '第${chapterNumber + 1}章标题';
                  final nextChapterRole = nextChapterInfo?['role'] ?? '高潮铺垫';
                  final nextChapterPurpose = nextChapterInfo?['purpose'] ?? '为高潮做准备';
                  final nextChapterSuspenseLevel = nextChapterInfo?['suspense_level'] ?? '爆发';
                  final nextChapterForeshadowing = nextChapterInfo?['foreshadowing'] ?? '埋设线索C';
                  final nextChapterPlotTwistLevel = nextChapterInfo?['plot_twist_level'] ?? '★★☆☆☆';
                  final nextChapterSummary = nextChapterInfo?['summary'] ?? '简要描述第${chapterNumber + 1}章的内容';
                  
                  // 获取 short_summary (这里需要调用LLM来生成)
                  // 1. 读取前三章内容
                  String combinedText = '';
                  for (int i = 1; i < chapterNumber && i <= 3; i++) {
                    final chapterContent = await NovelFileService().readChapter(novelFolderName, i);
                    if (chapterContent != null) {
                      combinedText += '第$i章:\n$chapterContent\n\n';
                    }
                  }
                  
                  // 2. 构建提示词
                  final promptGeneratorForShortSummary = PromptGenerator();
                  final shortSummaryPrompt = promptGeneratorForShortSummary.generateShortSummaryPrompt(
                    combinedText: combinedText,
                    novelNumber: chapterNumber,
                    chapterTitle: chapterTitle,
                    chapterRole: chapterRole,
                    chapterPurpose: chapterPurpose,
                    suspenseLevel: suspenseLevel,
                    foreshadowing: foreshadowing,
                    plotTwistLevel: plotTwistLevel,
                    chapterSummary: chapterSummary,
                    nextChapterNumber: chapterNumber + 1,
                    nextChapterTitle: nextChapterTitle,
                    nextChapterRole: nextChapterRole,
                    nextChapterPurpose: nextChapterPurpose,
                    nextChapterSuspenseLevel: nextChapterSuspenseLevel,
                    nextChapterForeshadowing: nextChapterForeshadowing,
                    nextChapterPlotTwistLevel: nextChapterPlotTwistLevel,
                    nextChapterSummary: nextChapterSummary,
                  );
                  
                  // 3. 调用LLM服务获取摘要
                  String shortSummary;
                  try {
                    // 显示加载指示器
                    if (mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 20),
                                Text(AppLocalizations.of(context).translate('calling_llm')),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    
                    shortSummary = await LLMService().callLLM(shortSummaryPrompt, selectedLLMConfig);
                    
                    // 隐藏加载指示器
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                    
                    // 移除可能的前缀 "当前章节摘要: "
                    if (shortSummary.startsWith('当前章节摘要:')) {
                      shortSummary = shortSummary.substring('当前章节摘要:'.length).trim();
                    }
                  } catch (e) {
                    // 隐藏加载指示器
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                    
                    LoggerService().logError('Failed to generate short summary: $e');
                    shortSummary = '这里应该是通过LLM生成的当前章节摘要'; // Fallback
                  }
                  
                  // 构建后续章节提示词
                  final promptGenerator = PromptGenerator();
                  final prompt = promptGenerator.generateNextChapterDraftPrompt(
                    globalSummary: globalSummary,
                    previousChapterExcerpt: previousChapterExcerpt,
                    userGuidance: _contentGuidanceController.text,
                    characterState: characterState,
                    shortSummary: shortSummary,
                    novelNumber: chapterNumber,
                    chapterTitle: chapterTitle,
                    chapterRole: chapterRole,
                    chapterPurpose: chapterPurpose,
                    suspenseLevel: suspenseLevel,
                    foreshadowing: foreshadowing,
                    plotTwistLevel: plotTwistLevel,
                    chapterSummary: chapterSummary,
                    wordNumber: wordCount,
                    charactersInvolved: _coreCharactersController.text,
                    keyItems: _keyItemsController.text,
                    sceneLocation: _spatialCoordinatesController.text,
                    timeConstraint: _timePressureController.text,
                    nextChapterNumber: chapterNumber + 1,
                    nextChapterTitle: nextChapterTitle,
                    nextChapterRole: nextChapterRole,
                    nextChapterPurpose: nextChapterPurpose,
                    nextChapterSuspenseLevel: nextChapterSuspenseLevel,
                    nextChapterForeshadowing: nextChapterForeshadowing,
                    nextChapterPlotTwistLevel: nextChapterPlotTwistLevel,
                    nextChapterSummary: nextChapterSummary,
                  );
                  
                  // 弹出编辑框让用户编辑提示词
                  _showEditPromptDialog(prompt, (editedPrompt) {
                    // 后续逻辑暂时占位
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            ).translate('next_chapter_prompt_edited'),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// 显示编辑提示词对话框
  Future<void> _showEditPromptDialog(
    String initialPrompt,
    Function(String) onPromptEdited,
  ) async {
    final TextEditingController promptController = TextEditingController(
      text: initialPrompt,
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogLocalizations = AppLocalizations.of(dialogContext);
        final dialogNavigator = Navigator.of(dialogContext);

        return AlertDialog(
          title: Text(dialogLocalizations.translate('edit_prompt')),
          content: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.8,
            child: SingleChildScrollView(
              child: TextField(
                controller: promptController,
                maxLines: 15,
                decoration: InputDecoration(
                  hintText: dialogLocalizations.translate('enter_prompt_here'),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(dialogLocalizations.translate('cancel')),
              onPressed: () {
                dialogNavigator.pop();
              },
            ),
            TextButton(
              child: Text(dialogLocalizations.translate('save')),
              onPressed: () {
                // 保存编辑后的提示词并调用回调函数
                onPromptEdited(promptController.text);
                dialogNavigator.pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// 显示编辑提示词对话框 (非第一章)，包含LLM配置选择
  // ignore: unused_element
  Future<void> _showEditPromptDialogWithLLMSelection(
    String initialPrompt,
    Function(String, String) onPromptEditedAndLLMSelected, // 回调函数增加LLM配置参数
  ) async {
    final TextEditingController promptController = TextEditingController(
      text: initialPrompt,
    );
    
    // 获取可用的LLM配置列表
    List<String> llmConfigNames = ['默认配置']; // 默认值，防止空列表
    String? defaultLLMConfigName;
    try {
      final config = ConfigService().getAll();
      if (config != null && 
          config.containsKey('llm_configs') && 
          config['llm_configs'] is Map) {
        final keys = (config['llm_configs'] as Map).keys.toList();
        if (keys.isNotEmpty) {
          llmConfigNames = keys.cast<String>(); // 确保类型正确
        }
      }
      // 获取默认配置（如果有）
      if (config != null && 
          config.containsKey('choose_configs') && 
          config['choose_configs'] is Map &&
          (config['choose_configs'] as Map).containsKey('prompt_draft_llm')) {
        defaultLLMConfigName = (config['choose_configs'] as Map)['prompt_draft_llm'] as String?;
      }
    } catch (e) {
      // 如果获取配置失败，使用默认列表
    }
    
    // 默认选中的配置
    String selectedLLMConfig = defaultLLMConfigName ?? (llmConfigNames.isNotEmpty ? llmConfigNames.first : '默认配置');

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogLocalizations = AppLocalizations.of(dialogContext);
        final dialogNavigator = Navigator.of(dialogContext);

        return AlertDialog(
          title: Text(dialogLocalizations.translate('edit_prompt_and_select_llm')),
          content: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: promptController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: dialogLocalizations.translate('enter_prompt_here'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 添加LLM配置选择下拉框
                  DropdownButtonFormField<String>(
                    initialValue: selectedLLMConfig,
                    items: llmConfigNames.map<DropdownMenuItem<String>>((String name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        // 注意：这里不能直接修改_state_中的变量，因为这个对话框有自己的context
                        // 我们需要在_onChanged_回调中处理
                      }
                    },
                    decoration: InputDecoration(
                      labelText: dialogLocalizations.translate('select_llm_config'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(dialogLocalizations.translate('cancel')),
              onPressed: () {
                dialogNavigator.pop();
              },
            ),
            TextButton(
              child: Text(dialogLocalizations.translate('save')),
              onPressed: () {
                // 保存编辑后的提示词和选择的LLM配置并调用回调函数
                // 由于DropdownButtonFormField的value属性需要在父组件中管理状态，这里我们直接使用selectedLLMConfig
                onPromptEditedAndLLMSelected(promptController.text, selectedLLMConfig);
                dialogNavigator.pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final selectedNovel = context.watch<SelectedNovelProvider>().selectedNovel;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 生成章节按钮
            ElevatedButton.icon(
              onPressed: selectedNovel != null
                  ? () => _showGenerateChapterDialog(selectedNovel)
                  : null, // 当未选择小说时禁用按钮
              icon: const Icon(Icons.auto_stories),
              label: Text(localizations.translate('generate_chapter')),
            ),
          ],
        ),
      ),
    );
  }
}