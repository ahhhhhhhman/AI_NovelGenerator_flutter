import 'dart:io';
import 'package:flutter/material.dart';
import '../../presentation/widgets/navigation_drawer.dart';
import '../../presentation/widgets/novel_selector_dropdown.dart';
import '../../app/localizations/app_localizations.dart';
import '../../domain/services/novel_folder_service.dart';
import '../../domain/services/logger_service.dart';
import 'main_features_page.dart';
import 'novel_architecture_page.dart';
import 'chapter_blueprint_page.dart';
import 'character_status_page.dart';
import 'full_text_overview_page.dart';
import 'chapter_management_page.dart';
import 'other_settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GlobalKey<NovelSelectorDropdownState> _novelSelectorKey =
      GlobalKey<NovelSelectorDropdownState>();

  final List<Widget> _pages = [
    const MainFeaturesPage(),
    const NovelArchitecturePage(),
    const ChapterBlueprintPage(),
    const CharacterStatusPage(),
    const FullTextOverviewPage(),
    const ChapterManagementPage(),
    const OtherSettingsPage(),
  ];

  // 页面标题列表，与导航项对应
  final List<String> _pageTitles = [
    'nav_main_features',
    'nav_novel_architecture',
    'nav_chapter_blueprint',
    'nav_character_status',
    'nav_full_text_overview',
    'nav_chapter_management',
    'nav_other_settings',
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// 显示添加小说对话框
  Future<void> _showAddNovelDialog() async {
    final localizations = AppLocalizations.of(context);
    String novelName = '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.translate('add_novel')),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: localizations.translate('enter_novel_name'),
            ),
            onChanged: (value) {
              novelName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.translate('cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(localizations.translate('confirm')),
              onPressed: () async {
                if (novelName.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  await _createNovelFolder(novelName.trim());
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// 创建小说文件夹
  Future<void> _createNovelFolder(String novelName) async {
    final localizations = AppLocalizations.of(context);
    try {
      final novelsPath = await NovelFolderService().getNovelsFolderPath();
      final novelPath = '$novelsPath/$novelName';
      final novelDir = Directory(novelPath);

      if (await novelDir.exists()) {
        // 如果文件夹已存在，显示错误消息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.translateWithArgs('novel_already_exists', [
                  novelName,
                ]),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        LoggerService().logWarning(
          'Attempted to create novel folder that already exists: $novelName',
        );
      } else {
        // 创建新的小说文件夹
        await novelDir.create(recursive: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.translateWithArgs('novel_created_successfully', [
                  novelName,
                ]),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        LoggerService().logInfo('Created new novel folder: $novelName');

        // 刷新小说选择下拉框
        _novelSelectorKey.currentState?.refreshNovelFolders();
      }
    } catch (e) {
      LoggerService().logError('Failed to create novel folder: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.translateWithArgs('failed_to_create_novel', [
                novelName,
              ]),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.translate(_pageTitles[_selectedIndex])),
            const SizedBox(width: 16),
            NovelSelectorDropdown(
              key: _novelSelectorKey,
              onSelected: (selectedFolder) {
                // 处理选择的小说文件夹
                if (selectedFolder != null) {
                  // 这里可以添加处理逻辑
                  // print('Selected novel folder: $selectedFolder');
                }
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddNovelDialog,
              tooltip: localizations.translate('add_novel'),
            ),
          ],
        ),
      ),
      drawer: AppNavigationDrawer(
        onDestinationSelected: _onDestinationSelected,
        selectedIndex: _selectedIndex,
      ),
      body: SingleChildScrollView(child: _pages[_selectedIndex]),
    );
  }
}
