import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'po/po_localizations.dart';
import 'pages/home_page.dart';
import 'pages/generator_page.dart';
import 'pages/favorites_page.dart';
import 'pages/settings_page.dart';
import 'pages/profile_page.dart';
import 'pages/search_page.dart';
import 'pages/other_settings_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'AI Novel Generator',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.limeAccent),
        ),
        home: MyHomePage(),
        localizationsDelegates: const [
          PoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // 英语
          Locale('zh'), // 中文
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          // 默认使用英语
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
      ),
    );
  }
}

// ...

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // ↓ Add the code below.
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

// ...

// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = GeneratorPage();
        break;
      case 2:
        page = FavoritesPage();
        break;
      case 3:
        page = SettingsPage();
        break;
      case 4:
        page = ProfilePage();
        break;
      case 5:
        page = SearchPage();
        break;
      case 6:
        page = OtherSettingsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // 安全地获取本地化实例
        final localizations = PoLocalizations.of(context);
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text(localizations.tr('main_features_tab')),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.account_tree),
                      label: Text(localizations.tr('novel_structure_tab')),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.chrome_reader_mode),
                      label: Text(localizations.tr('chapter_blueprint_tab')),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.group),
                      label: Text(localizations.tr('character_status_tab')),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.menu_book),
                      label: Text(localizations.tr('full_text_overview_tab')),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.folder_shared),
                      label: Text(localizations.tr('chapter_management_tab')),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text(localizations.tr('other_settings_tab')),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );  
  }
}
