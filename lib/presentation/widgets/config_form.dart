import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';

class ConfigForm extends StatelessWidget {
  const ConfigForm({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: localizations.translate('api_key_label'),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            labelText: localizations.translate('model_parameters_label'),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}