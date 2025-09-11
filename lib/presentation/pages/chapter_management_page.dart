import 'package:flutter/material.dart';
import '../../presentation/widgets/novel_selector_dropdown.dart';
import '../../app/localizations/app_localizations.dart';

class ChapterManagementPage extends StatelessWidget {
  const ChapterManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 添加小说选择下拉框
            Align(
              alignment: Alignment.topLeft,
              child: NovelSelectorDropdown(
                onSelected: (selectedFolder) {
                  // 处理选择的小说文件夹
                  if (selectedFolder != null) {
                    // 这里可以添加处理逻辑
                    // print('Selected novel folder: $selectedFolder');
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                localizations.translate('chapter_management_page_placeholder'),
                style: const TextStyle(fontFamily: 'Microsoft YaHei'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}