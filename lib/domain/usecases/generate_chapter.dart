import '../../data/models/chapter.dart';
import '../../data/models/novel_setting.dart';
import '../../data/repositories/novel_repository.dart';

class GenerateChapter {
  final NovelRepository repository;

  GenerateChapter(this.repository);

  Future<Chapter> execute(int chapterNumber, NovelSetting setting) async {
    // Business logic for generating a chapter
    // This is a placeholder for actual implementation
    return await repository.generateChapter(chapterNumber, setting);
  }
}