import 'package:flutter/material.dart';
import '../po/po_localizations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(PoLocalizations.of(context).tr('character_status_content')),
    );
  }
}