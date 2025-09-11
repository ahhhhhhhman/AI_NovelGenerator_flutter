import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/localizations/app_localizations.dart';
import '../../data/datasources/local/novel_file_service.dart';
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
    // 如果有未保存的更改，提示用户
    if (_selectedFolder != null && _directoryContent != _textController.text) {
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
      if (_selectedFolder != null && _directoryContent != _textController.text) {
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
      final success = await NovelFileService().saveDirectory(folderName, content);
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
              content: Text(AppLocalizations.of(context).translate('save_successful')),
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
              content: Text(AppLocalizations.of(context).translate('save_failed')),
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
            content: Text(AppLocalizations.of(context).translate('save_failed')),
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
                  await _saveDirectoryContent(_selectedFolder!, _textController.text);
                  onConfirmed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // 如果有未保存的更改，在页面销毁前保存
    if (_selectedFolder != null && _directoryContent != _textController.text) {
      _saveDirectoryContent(_selectedFolder!, _textController.text);
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
    if (selectedNovel != _selectedFolder) {
      _onNovelSelected(selectedNovel);
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
            if (_isSaving)
              const SizedBox(height: 8),
            
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
              // 文件不存在时显示提示
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
              )
            else
              // 文本编辑框
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
      ),
    );
  }
}