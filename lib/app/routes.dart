import 'package:flutter/material.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/setting_page.dart';
import '../presentation/pages/novel_editor_page.dart';
import '../presentation/pages/character_library_page.dart';
import '../presentation/pages/log_page.dart';
import '../presentation/pages/large_model_settings_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/setting':
        return MaterialPageRoute(builder: (_) => const SettingPage());
      case '/editor':
        return MaterialPageRoute(builder: (_) => const NovelEditorPage());
      case '/character':
        return MaterialPageRoute(builder: (_) => const CharacterLibraryPage());
      case '/log':
        return MaterialPageRoute(builder: (_) => const LogPage());
      case '/large_model_settings':
        return MaterialPageRoute(builder: (_) => const LargeModelSettingsPage());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('Page not found')),
        );
      },
    );
  }
}
