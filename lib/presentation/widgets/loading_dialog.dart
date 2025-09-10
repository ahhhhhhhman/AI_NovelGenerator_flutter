import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';

class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({
    super.key,
    this.message = 'loading', // Key for localization
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    String displayMessage = message == 'loading' 
        ? localizations.translate('loading') 
        : message;
        
    return AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 20),
          Text(displayMessage),
        ],
      ),
    );
  }
}