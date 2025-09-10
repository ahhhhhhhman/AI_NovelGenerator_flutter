import 'package:flutter/material.dart';
import '../po/po_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = PoLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.tr('main_features_title'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          Text(
            localizations.tr('main_features_description'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.tr('main_features_welcome_title'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    localizations.tr('main_features_welcome_description'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}