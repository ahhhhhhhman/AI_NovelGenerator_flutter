import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/localizations/app_localizations.dart';
import '../../data/datasources/local/novel_file_service.dart';
import '../pages/novel_architecture_page.dart'; // 导入 SelectedNovelProvider

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
  final TextEditingController _spatialCoordinatesController = TextEditingController();

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

  /// 显示生成章节对话框
  Future<void> _showGenerateChapterDialog(String novelFolderName) async {
    // 初始化章节号为最大章节号+1
    await _setNextChapterNumber(novelFolderName);

    // 检查State是否仍然挂载
    if (!mounted) return;

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        final dialogLocalizations = AppLocalizations.of(dialogContext);
        final dialogNavigator = Navigator.of(dialogContext);
        final dialogScaffoldMessenger = ScaffoldMessenger.of(dialogContext);

        return AlertDialog(
          title: Text(dialogLocalizations.translate('generate_chapter')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 60,
                  child: TextField(
                    controller: _chapterNumberController,
                    decoration: InputDecoration(
                      labelText: dialogLocalizations.translate('chapter_number'),
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
                      labelText: dialogLocalizations.translate('core_characters'),
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
                      labelText: dialogLocalizations.translate('spatial_coordinates'),
                    ),
                  ),
                ),
              ],
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

                // TODO: 实现生成章节的逻辑
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        ).translate('chapter_generation_not_implemented'),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
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
