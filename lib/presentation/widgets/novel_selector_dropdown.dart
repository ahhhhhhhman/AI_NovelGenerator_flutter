import 'package:flutter/material.dart';
import '../../domain/services/novel_folder_service.dart';
import '../../domain/services/logger_service.dart';
import '../../app/localizations/app_localizations.dart';

// 将状态类改为公开的
class NovelSelectorDropdownState extends State<NovelSelectorDropdown> {
  late Future<List<String>> _novelFoldersFuture;
  String? _selectedFolder;

  @override
  void initState() {
    super.initState();
    _selectedFolder = widget.initialValue;
    _novelFoldersFuture = NovelFolderService().getNovelFolderNames();
  }

  // 刷新小说文件夹列表的方法
  void refreshNovelFolders() {
    setState(() {
      _novelFoldersFuture = NovelFolderService().getNovelFolderNames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return FutureBuilder<List<String>>(
      future: _novelFoldersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return DropdownButton<String>(
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(
                  localizations.translate('loading'),
                  style: const TextStyle(fontFamily: 'Microsoft YaHei'),
                ),
              ),
            ],
            onChanged: null,
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          LoggerService().logError('Failed to load novel folders: ${snapshot.error}');
          return DropdownButton<String>(
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(
                  localizations.translate('loading_failed'),
                  style: const TextStyle(fontFamily: 'Microsoft YaHei'),
                ),
              ),
            ],
            onChanged: null,
          );
        }

        final folders = snapshot.data!;
        
        // 如果没有文件夹，显示提示
        if (folders.isEmpty) {
          return DropdownButton<String>(
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(
                  localizations.translate('no_novel_available'),
                  style: const TextStyle(fontFamily: 'Microsoft YaHei'),
                ),
              ),
            ],
            onChanged: null,
          );
        }

        return DropdownButton<String>(
          value: _selectedFolder,
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                localizations.translate('select_novel'),
                style: const TextStyle(fontFamily: 'Microsoft YaHei'),
              ),
            ),
            ...folders.map((folder) {
              return DropdownMenuItem(
                value: folder,
                child: Text(
                  folder,
                  style: const TextStyle(fontFamily: 'Microsoft YaHei'),
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedFolder = value;
            });
            if (widget.onSelected != null) {
              widget.onSelected!(value);
              if (value != null) {
                LoggerService().logInfo('Selected novel folder: $value');
              }
            }
          },
        );
      },
    );
  }
}

class NovelSelectorDropdown extends StatefulWidget {
  final Function(String?)? onSelected;
  final String? initialValue;

  const NovelSelectorDropdown({
    super.key,
    this.onSelected,
    this.initialValue,
  });

  @override
  State<NovelSelectorDropdown> createState() => NovelSelectorDropdownState();
}