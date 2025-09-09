import 'package:flutter/material.dart';
import '../po/po_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(PoLocalizations.of(context).tr('chapter_blueprint_content')),
    );
  }
}