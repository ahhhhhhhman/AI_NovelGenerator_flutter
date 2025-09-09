import 'package:flutter/material.dart';
import '../po/po_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(PoLocalizations.of(context).tr('main_features_content')),
    );
  }
}