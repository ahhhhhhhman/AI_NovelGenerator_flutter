import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class NovelFolderService {
  static final NovelFolderService _instance = NovelFolderService._internal();
  factory NovelFolderService() => _instance;
  NovelFolderService._internal();

  /// 获取novels文件夹路径
  Future<String> getNovelsFolderPath() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final novelsPath = path.join(
      appDocDir.path,
      'novel_generator_flutter',
      'novels',
    );
    
    // 如果novels文件夹不存在则创建
    final novelsDir = Directory(novelsPath);
    if (!await novelsDir.exists()) {
      await novelsDir.create(recursive: true);
    }
    
    return novelsPath;
  }

  /// 获取novels文件夹内的所有子文件夹名
  Future<List<String>> getNovelFolderNames() async {
    try {
      final novelsPath = await getNovelsFolderPath();
      final novelsDir = Directory(novelsPath);
      
      if (!await novelsDir.exists()) {
        return [];
      }
      
      final List<String> folderNames = [];
      await for (final entity in novelsDir.list()) {
        if (entity is Directory) {
          folderNames.add(path.basename(entity.path));
        }
      }
      
      return folderNames;
    } catch (e) {
      // 发生错误时返回空列表
      return [];
    }
  }
}