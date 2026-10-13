import '../../core/services/storage_service.dart';
import '../../domain/repositories/progress_repository.dart';
import '../models/user_progress_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  static const String _storageKey = 'user_learning_progress_v1';
  final StorageService _storageService;

  ProgressRepositoryImpl(this._storageService);

  @override
  Future<UserProgressModel> getProgress() async {
    final raw = _storageService.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return UserProgressModel.initial();
    }
    try {
      return UserProgressModel.fromJson(raw);
    } catch (_) {
      return UserProgressModel.initial();
    }
  }

  @override
  Future<void> saveProgress(UserProgressModel progress) async {
    await _storageService.setString(_storageKey, progress.toJson());
  }

  @override
  Future<void> markLessonComplete(String lessonId, {int earnedXp = 20}) async {
    final current = await getProgress();
    final updatedLessons = Set<String>.from(current.completedLessonIds)..add(lessonId);
    final updated = current.copyWith(
      completedLessonIds: updatedLessons,
      totalXp: current.totalXp + earnedXp,
      lastActiveDate: DateTime.now().toIso8601String().substring(0, 10),
    );
    await saveProgress(updated);
  }

  @override
  Future<void> recordQuizResult(String unitId, int scorePercent, {int earnedXp = 50}) async {
    final current = await getProgress();
    final prevScore = current.unitQuizScores[unitId] ?? 0;
    final updatedScores = Map<String, int>.from(current.unitQuizScores);
    if (scorePercent > prevScore) {
      updatedScores[unitId] = scorePercent;
    }
    final bonusXp = scorePercent >= 80 ? earnedXp : (earnedXp / 2).round();
    final updated = current.copyWith(
      unitQuizScores: updatedScores,
      totalXp: current.totalXp + bonusXp,
      lastActiveDate: DateTime.now().toIso8601String().substring(0, 10),
    );
    await saveProgress(updated);
  }

  @override
  Future<void> resetProgress() async {
    await _storageService.remove(_storageKey);
  }
}
