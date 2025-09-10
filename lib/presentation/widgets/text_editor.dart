import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';

class TextEditor extends StatelessWidget {
  final String initialText;
  final Function(String) onTextChanged;
  final int maxLines;

  const TextEditor({
    super.key,
    required this.initialText,
    required this.onTextChanged,
    this.maxLines = 10,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return TextField(
      controller: TextEditingController(text: initialText),
      maxLines: maxLines,
      onChanged: onTextChanged,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: localizations.translate('text_editor_hint'),
      ),
    );
  }
}