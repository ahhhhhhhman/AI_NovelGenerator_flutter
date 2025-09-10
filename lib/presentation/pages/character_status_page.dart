import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';

class CharacterStatusPage extends StatelessWidget {
  const CharacterStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return const Center(
      child: Text('Character Status Page - Placeholder content'),
    );
  }
}