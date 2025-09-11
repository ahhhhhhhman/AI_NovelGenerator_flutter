import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'routes.dart';
import 'localizations/app_localizations.dart';
import '../presentation/theme/theme.dart';
import '../presentation/pages/novel_architecture_page.dart';

class NovelGeneratorApp extends StatelessWidget {
  const NovelGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SelectedNovelProvider()),
      ],
      child: MaterialApp(
        title: 'Novel Generator',
        theme: appTheme,
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('zh', ''), // Chinese
        ],
      ),
    );
  }
}