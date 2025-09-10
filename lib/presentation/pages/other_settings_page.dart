import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';

class OtherSettingsPage extends StatelessWidget {
  const OtherSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return const Center(
      child: Text('Other Settings Page - Placeholder content'),
    );
  }
}