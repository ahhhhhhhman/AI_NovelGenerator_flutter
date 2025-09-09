import 'package:flutter/material.dart';
import '../po/po_localizations.dart';

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(PoLocalizations.of(context).tr('generator_page_content')),
    );
  }
}
