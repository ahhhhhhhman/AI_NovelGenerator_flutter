import 'package:flutter/material.dart';
import '../po/po_localizations.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(PoLocalizations.of(context).tr('full_text_overview_content')),
    );
  }
}