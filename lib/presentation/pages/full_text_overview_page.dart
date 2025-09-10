import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';

class FullTextOverviewPage extends StatelessWidget {
  const FullTextOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return const Center(
      child: Text('Full Text Overview Page - Placeholder content'),
    );
  }
}