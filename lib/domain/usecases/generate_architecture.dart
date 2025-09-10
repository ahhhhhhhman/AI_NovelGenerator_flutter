import '../../data/models/novel_setting.dart';
import '../../data/repositories/novel_repository.dart';

class GenerateArchitecture {
  final NovelRepository repository;

  GenerateArchitecture(this.repository);

  Future<NovelSetting> execute(Map<String, dynamic> params) async {
    // Business logic for generating novel architecture
    // This is a placeholder for actual implementation
    return await repository.generateNovelArchitecture(params);
  }
}