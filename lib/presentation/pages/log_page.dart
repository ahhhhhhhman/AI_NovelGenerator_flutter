import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate('log_title'))),
      body: const Center(
        child: Text('Log Page - View application logs'),
      ),
    );
  }
}