import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate('settings_title'))),
      body: SingleChildScrollView(
        child: Center(
          child: Text('Settings Page - Configure API keys and model parameters'),
        ),
      ),
    );
  }
}