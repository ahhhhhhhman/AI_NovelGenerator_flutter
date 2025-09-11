import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/localizations/app_localizations.dart';
import '../../data/datasources/local/novel_file_service.dart';
import '../pages/novel_architecture_page.dart';

class ChapterManagementPage extends StatefulWidget {
  const ChapterManagementPage({super.key});

  @override
  State<ChapterManagementPage> createState() => _ChapterManagementPageState();
}

class _ChapterManagementPageState extends State<ChapterManagementPage> {
  String? _selectedFolder;
  List<int> _chapterNumbers = [];
  int? _currentChapterNumber;
  String? _chapterContent;
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
    if (_selectedFolder != null && _chapterContent != _textController.text) {
      _confirmSaveBeforeChange(() {
        setState(() {
          _selectedFolder = folderName;
          _chapterNumbers = [];
          _currentChapterNumber = null;
          _chapterContent = null;
          _contentExists = false;
          _textController.text = '';
        });

        if (folderName != null) {
          _loadChapterList(folderName);
        }
      });
    } else {
      setState(() {
        _selectedFolder = folderName;
        _chapterNumbers = [];
        _currentChapterNumber = null;
        _chapterContent = null;
        _contentExists = false;
        _textController.text = '';
      });

      if (folderName != null) {
        _loadChapterList(folderName);
      }
    }
  }

  // 加载章节列表
  Future<void> _loadChapterList(String folderName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final chapterNumbers = await NovelFileService().getChapterNumbers(folderName);
      setState(() {
        _chapterNumbers = chapterNumbers;
        _isLoading = false;
        
        // 如果有章节，选择第一个章节
        if (chapterNumbers.isNotEmpty) {
          _loadChapterContent(folderName, chapterNumbers[0]);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _chapterNumbers = [];
        _currentChapterNumber = null;
        _chapterContent = null;
        _contentExists = false;
        _textController.text = '';
      });
    }
  }

  // 加载章节内容
  Future<void> _loadChapterContent(String folderName, int chapterNumber) async {
    // 如果有未保存的更改，提示用户
    if (_currentChapterNumber != null && _chapterContent != _textController.text) {
      _confirmSaveBeforeChange(() {
        _loadChapterContentInternal(folderName, chapterNumber);
      });
    } else {
      _loadChapterContentInternal(folderName, chapterNumber);
    }
  }

  // 内部加载章节内容的方法
  Future<void> _loadChapterContentInternal(String folderName, int chapterNumber) async {
    setState(() {
      _isLoading = true;
      _currentChapterNumber = chapterNumber;
    });

    try {
      final content = await NovelFileService().readChapter(folderName, chapterNumber);
      setState(() {
        _chapterContent = content;
        _contentExists = content != null;
        _textController.text = content ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _chapterContent = null;
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
      if (_selectedFolder != null && _currentChapterNumber != null && 
          _chapterContent != _textController.text) {
        _saveChapterContent(_selectedFolder!, _currentChapterNumber!, _textController.text);
      }
    });
  }

  // 保存章节内容
  Future<void> _saveChapterContent(String folderName, int chapterNumber, String content) async {
    setState(() {
      _isSaving = true;
    });
    
    try {
      final success = await NovelFileService().saveChapter(folderName, chapterNumber, content);
      if (success) {
        setState(() {
          _chapterContent = content;
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

  // 上一章
  void _previousChapter() {
    if (_selectedFolder != null && _currentChapterNumber != null && _chapterNumbers.isNotEmpty) {
      final currentIndex = _chapterNumbers.indexOf(_currentChapterNumber!);
      if (currentIndex > 0) {
        _loadChapterContent(_selectedFolder!, _chapterNumbers[currentIndex - 1]);
      }
    }
  }

  // 下一章
  void _nextChapter() {
    if (_selectedFolder != null && _currentChapterNumber != null && _chapterNumbers.isNotEmpty) {
      final currentIndex = _chapterNumbers.indexOf(_currentChapterNumber!);
      if (currentIndex < _chapterNumbers.length - 1) {
        _loadChapterContent(_selectedFolder!, _chapterNumbers[currentIndex + 1]);
      }
    }
  }

  // 章节选择变化
  void _onChapterChanged(int? chapterNumber) {
    if (_selectedFolder != null && chapterNumber != null) {
      _loadChapterContent(_selectedFolder!, chapterNumber);
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
                if (_selectedFolder != null && _currentChapterNumber != null) {
                  await _saveChapterContent(_selectedFolder!, _currentChapterNumber!, _textController.text);
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
    if (_selectedFolder != null && _currentChapterNumber != null && _chapterContent != _textController.text) {
      _saveChapterContent(_selectedFolder!, _currentChapterNumber!, _textController.text);
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
            
            // 章节导航控件
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
            else
              Row(
                children: [
                  // 上一章按钮
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: (_currentChapterNumber != null && 
                               _chapterNumbers.isNotEmpty && 
                               _chapterNumbers.indexOf(_currentChapterNumber!) > 0)
                        ? _previousChapter
                        : null,
                  ),
                  
                  // 章节选择下拉框
                  Expanded(
                    child: _isLoading && _chapterNumbers.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButton<int>(
                            value: _currentChapterNumber,
                            items: _chapterNumbers.map((chapterNumber) {
                              return DropdownMenuItem(
                                value: chapterNumber,
                                child: Text(
                                  '${localizations.translate('chapter')} $chapterNumber',
                                  style: const TextStyle(fontFamily: 'Microsoft YaHei'),
                                ),
                              );
                            }).toList(),
                            onChanged: _onChapterChanged,
                            isExpanded: true,
                          ),
                  ),
                  
                  // 下一章按钮
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: (_currentChapterNumber != null && 
                               _chapterNumbers.isNotEmpty && 
                               _chapterNumbers.indexOf(_currentChapterNumber!) < _chapterNumbers.length - 1)
                        ? _nextChapter
                        : null,
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // 文本编辑区域
            if (_selectedFolder != null && _isLoading && _chapterNumbers.isNotEmpty)
              // 加载中显示进度指示器
              const Center(child: CircularProgressIndicator())
            else if (_selectedFolder != null && _chapterNumbers.isEmpty)
              // 无章节时显示提示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  localizations.translate('no_chapters_available'),
                  style: const TextStyle(fontFamily: 'Microsoft YaHei'),
                ),
              )
            else if (_selectedFolder != null && _currentChapterNumber == null)
              // 未选择章节时显示提示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  localizations.translate('select_chapter_first'),
                  style: const TextStyle(fontFamily: 'Microsoft YaHei'),
                ),
              )
            else if (_selectedFolder != null && !_contentExists && _chapterContent == null)
              // 章节文件不存在时显示提示
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  localizations.translate('chapter_not_exists'),
                  style: const TextStyle(fontFamily: 'Microsoft YaHei'),
                ),
              )
            else if (_selectedFolder != null)
              // 文本编辑框
              TextField(
                controller: _textController,
                maxLines: 20,
                decoration: InputDecoration(
                  hintText: localizations.translate('chapter_content_hint'),
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