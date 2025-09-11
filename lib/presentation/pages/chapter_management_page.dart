import 'package:flutter/material.dart';
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