import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';

class NovelArchitecturePage extends StatelessWidget {
  const NovelArchitecturePage({super.key});

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
                localizations.translate('novel_architecture_page_placeholder'),
                style: const TextStyle(fontFamily: 'Microsoft YaHei'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}