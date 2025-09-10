import 'package:flutter/material.dart';
import '../../app/localizations/app_localizations.dart';

class AppNavigationDrawer extends StatelessWidget {
  final void Function(int) onDestinationSelected;
  final int selectedIndex;

  const AppNavigationDrawer({
    super.key,
    required this.onDestinationSelected,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              localizations.translate('app_title'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(localizations.translate('nav_main_features')),
            selected: selectedIndex == 0,
            onTap: () {
              Navigator.pop(context);
              onDestinationSelected(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_tree),
            title: Text(localizations.translate('nav_novel_architecture')),
            selected: selectedIndex == 1,
            onTap: () {
              Navigator.pop(context);
              onDestinationSelected(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: Text(localizations.translate('nav_chapter_blueprint')),
            selected: selectedIndex == 2,
            onTap: () {
              Navigator.pop(context);
              onDestinationSelected(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(localizations.translate('nav_character_status')),
            selected: selectedIndex == 3,
            onTap: () {
              Navigator.pop(context);
              onDestinationSelected(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(localizations.translate('nav_full_text_overview')),
            selected: selectedIndex == 4,
            onTap: () {
              Navigator.pop(context);
              onDestinationSelected(4);
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books),
            title: Text(localizations.translate('nav_chapter_management')),
            selected: selectedIndex == 5,
            onTap: () {
              Navigator.pop(context);
              onDestinationSelected(5);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(localizations.translate('nav_other_settings')),
            selected: selectedIndex == 6,
            onTap: () {
              Navigator.pop(context);
              onDestinationSelected(6);
            },
          ),
        ],
      ),
    );
  }
}