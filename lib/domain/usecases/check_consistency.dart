import '../../data/models/chapter.dart';
import '../../data/models/character.dart';
import '../../data/repositories/novel_repository.dart';

class CheckConsistency {
  final NovelRepository repository;

  CheckConsistency(this.repository);

  Future<bool> execute(List<Chapter> chapters, List<Character> characters) async {
    // Business logic for checking consistency
    // This is a placeholder for actual implementation
    return await repository.checkConsistency(chapters, characters);
  }
}