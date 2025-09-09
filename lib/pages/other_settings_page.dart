import 'package:flutter/material.dart';
import '../po/po_localizations.dart';

class OtherSettingsPage extends StatelessWidget {
  const OtherSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(PoLocalizations.of(context).tr('other_settings_content')),
    );
  }
}