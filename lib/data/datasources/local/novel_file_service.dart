import 'dart:io';
import 'package:path/path.dart' as path;
import '../../../domain/services/novel_folder_service.dart';

class NovelFileService {
  static final NovelFileService _instance = NovelFileService._internal();
  factory NovelFileService() => _instance;
  NovelFileService._internal();

  /// 获取小说架构文件路径 (Novel_architecture.txt)
  Future<String> _getArchitectureFilePath(String novelFolderName) async {
    final novelsPath = await NovelFolderService().getNovelsFolderPath();
    return path.join(novelsPath, novelFolderName, 'Novel_architecture.txt');
  }

  /// 获取章节蓝图文件路径 (Novel_directory.txt)
  Future<String> _getDirectoryFilePath(String novelFolderName) async {
    final novelsPath = await NovelFolderService().getNovelsFolderPath();
    return path.join(novelsPath, novelFolderName, 'Novel_directory.txt');
  }

  /// 获取角色状态文件路径 (character_state.txt)
  Future<String> _getCharacterStateFilePath(String novelFolderName) async {
    final novelsPath = await NovelFolderService().getNovelsFolderPath();
    return path.join(novelsPath, novelFolderName, 'character_state.txt');
  }

  /// 获取全文概述文件路径 (global_summary.txt)
  Future<String> _getGlobalSummaryFilePath(String novelFolderName) async {
    final novelsPath = await NovelFolderService().getNovelsFolderPath();
    return path.join(novelsPath, novelFolderName, 'global_summary.txt');
  }

  /// 获取章节文件夹路径
  Future<String> _getChaptersFolderPath(String novelFolderName) async {
    final novelsPath = await NovelFolderService().getNovelsFolderPath();
    return path.join(novelsPath, novelFolderName, 'chapters');
  }

  /// 获取章节文件路径 (chapter_数字.txt)
  Future<String> _getChapterFilePath(String novelFolderName, int chapterNumber) async {
    final chaptersPath = await _getChaptersFolderPath(novelFolderName);
    return path.join(chaptersPath, 'chapter_$chapterNumber.txt');
  }

  /// 读取小说架构内容
  Future<String?> readArchitecture(String novelFolderName) async {
    try {
      final filePath = await _getArchitectureFilePath(novelFolderName);
      final file = File(filePath);
      
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      // 发生错误时返回null
      return null;
    }
  }

  /// 保存小说架构内容
  Future<bool> saveArchitecture(String novelFolderName, String content) async {
    try {
      final filePath = await _getArchitectureFilePath(novelFolderName);
      final file = File(filePath);
      
      // 确保目录存在
      await file.parent.create(recursive: true);
      
      // 写入内容
      await file.writeAsString(content);
      return true;
    } catch (e) {
      // 发生错误时返回false
      return false;
    }
  }

  /// 读取章节蓝图内容
  Future<String?> readDirectory(String novelFolderName) async {
    try {
      final filePath = await _getDirectoryFilePath(novelFolderName);
      final file = File(filePath);
      
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      // 发生错误时返回null
      return null;
    }
  }

  /// 保存章节蓝图内容
  Future<bool> saveDirectory(String novelFolderName, String content) async {
    try {
      final filePath = await _getDirectoryFilePath(novelFolderName);
      final file = File(filePath);
      
      // 确保目录存在
      await file.parent.create(recursive: true);
      
      // 写入内容
      await file.writeAsString(content);
      return true;
    } catch (e) {
      // 发生错误时返回false
      return false;
    }
  }

  /// 读取角色状态内容
  Future<String?> readCharacterState(String novelFolderName) async {
    try {
      final filePath = await _getCharacterStateFilePath(novelFolderName);
      final file = File(filePath);
      
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      // 发生错误时返回null
      return null;
    }
  }

  /// 保存角色状态内容
  Future<bool> saveCharacterState(String novelFolderName, String content) async {
    try {
      final filePath = await _getCharacterStateFilePath(novelFolderName);
      final file = File(filePath);
      
      // 确保目录存在
      await file.parent.create(recursive: true);
      
      // 写入内容
      await file.writeAsString(content);
      return true;
    } catch (e) {
      // 发生错误时返回false
      return false;
    }
  }

  /// 读取全文概述内容
  Future<String?> readGlobalSummary(String novelFolderName) async {
    try {
      final filePath = await _getGlobalSummaryFilePath(novelFolderName);
      final file = File(filePath);
      
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      // 发生错误时返回null
      return null;
    }
  }

  /// 保存全文概述内容
  Future<bool> saveGlobalSummary(String novelFolderName, String content) async {
    try {
      final filePath = await _getGlobalSummaryFilePath(novelFolderName);
      final file = File(filePath);
      
      // 确保目录存在
      await file.parent.create(recursive: true);
      
      // 写入内容
      await file.writeAsString(content);
      return true;
    } catch (e) {
      // 发生错误时返回false
      return false;
    }
  }

  /// 获取章节文件列表
  Future<List<int>> getChapterNumbers(String novelFolderName) async {
    try {
      final chaptersPath = await _getChaptersFolderPath(novelFolderName);
      final chaptersDir = Directory(chaptersPath);
      
      if (!await chaptersDir.exists()) {
        return [];
      }
      
      final List<int> chapterNumbers = [];
      await for (final entity in chaptersDir.list()) {
        if (entity is File) {
          final fileName = path.basename(entity.path);
          // 匹配 chapter_数字.txt 格式
          final RegExp chapterRegExp = RegExp(r'^chapter_(\d+)\.txt$');
          final match = chapterRegExp.firstMatch(fileName);
          if (match != null) {
            final chapterNumber = int.parse(match.group(1)!);
            chapterNumbers.add(chapterNumber);
          }
        }
      }
      
      // 按数字排序
      chapterNumbers.sort();
      return chapterNumbers;
    } catch (e) {
      // 发生错误时返回空列表
      return [];
    }
  }

  /// 读取章节内容
  Future<String?> readChapter(String novelFolderName, int chapterNumber) async {
    try {
      final filePath = await _getChapterFilePath(novelFolderName, chapterNumber);
      final file = File(filePath);
      
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      // 发生错误时返回null
      return null;
    }
  }

  /// 保存章节内容
  Future<bool> saveChapter(String novelFolderName, int chapterNumber, String content) async {
    try {
      final filePath = await _getChapterFilePath(novelFolderName, chapterNumber);
      final file = File(filePath);
      
      // 确保目录存在
      await file.parent.create(recursive: true);
      
      // 写入内容
      await file.writeAsString(content);
      return true;
    } catch (e) {
      // 发生错误时返回false
      return false;
    }
  }
}