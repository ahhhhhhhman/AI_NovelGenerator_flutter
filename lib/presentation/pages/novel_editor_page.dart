import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';

class NovelEditorPage extends StatelessWidget {
  const NovelEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate('novel_editor_title'))),
      body: SingleChildScrollView(
        child: Center(
          child: Text('Novel Editor Page - Edit chapter content'),
        ),
      ),
    );
  }
}