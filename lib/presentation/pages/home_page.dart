import 'package:flutter/material.dart';
import '../../presentation/widgets/navigation_drawer.dart';
import '../../app/localizations/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate(_pageTitles[_selectedIndex])),
      ),
      drawer: AppNavigationDrawer(
        onDestinationSelected: _onDestinationSelected,
        selectedIndex: _selectedIndex,
      ),
      body: _pages[_selectedIndex],
    );
  }
}