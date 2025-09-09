import 'package:flutter/material.dart';
import '../po/po_localizations.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(PoLocalizations.of(context).tr('novel_structure_content')),
    );
  }
}