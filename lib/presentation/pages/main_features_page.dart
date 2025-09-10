import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';

class MainFeaturesPage extends StatelessWidget {
  const MainFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return const Center(
      child: Text('Main Features Page - Placeholder content'),
    );
  }
}