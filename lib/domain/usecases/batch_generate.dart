import '../../data/models/chapter.dart';
import '../../data/models/novel_setting.dart';
import '../../data/repositories/novel_repository.dart';

class BatchGenerate {
  final NovelRepository repository;

  BatchGenerate(this.repository);

  Future<List<Chapter>> execute(NovelSetting setting) async {
    // Business logic for batch generating chapters
    // This is a placeholder for actual implementation
    return await repository.batchGenerate(setting);
  }
}