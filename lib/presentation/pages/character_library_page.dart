import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';

class CharacterLibraryPage extends StatelessWidget {
  const CharacterLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate('character_library_title'))),
      body: const Center(
        child: Text('Character Library Page - Manage characters'),
      ),
    );
  }
}