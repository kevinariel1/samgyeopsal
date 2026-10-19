import '../../core/services/storage_service.dart';
import '../../domain/repositories/progress_repository.dart';
import '../models/quiz_attempt_model.dart';
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
  Future<int> recordQuizResult(
    String unitId,
    int scorePercent, {
    int totalQuizXp = 100,
    int? earnedXp,
  }) async {
    final quizTotalXp = earnedXp ?? totalQuizXp;
    final current = await getProgress();

    // 1. Maintain highest score percentage
    final prevScore = current.unitQuizScores[unitId] ?? 0;
    final updatedScores = Map<String, int>.from(current.unitQuizScores);
    if (scorePercent > prevScore) {
      updatedScores[unitId] = scorePercent;
    }

    // 2. EXP Calculation:
    // First attempt earns EXP equal to score percentage of totalQuizXp.
    // Retakes earn only remaining unclaimed EXP: max(0, newAttemptExp - storedMaxExp).
    final attemptExp = ((scorePercent.clamp(0, 100) / 100.0) * quizTotalXp).round();
    final prevMaxExp = current.quizHighestXp[unitId] ?? 0;
    final awardedExp = (attemptExp - prevMaxExp).clamp(0, quizTotalXp);

    final updatedQuizHighestXp = Map<String, int>.from(current.quizHighestXp);
    if (attemptExp > prevMaxExp) {
      updatedQuizHighestXp[unitId] = attemptExp;
    }

    final updated = current.copyWith(
      unitQuizScores: updatedScores,
      quizHighestXp: updatedQuizHighestXp,
      totalXp: current.totalXp + awardedExp,
      lastActiveDate: DateTime.now().toIso8601String().substring(0, 10),
    );
    await saveProgress(updated);
    return awardedExp;
  }

  @override
  Future<int> recordQuizAttempt(
    QuizAttemptModel attempt, {
    int totalQuizXp = 100,
    int? earnedXp,
  }) async {
    final quizTotalXp = earnedXp ?? totalQuizXp;
    final current = await getProgress();

    // 1. Maintain highest score percentage
    final prevScore = current.unitQuizScores[attempt.unitId] ?? 0;
    final updatedScores = Map<String, int>.from(current.unitQuizScores);
    if (attempt.scorePercent > prevScore) {
      updatedScores[attempt.unitId] = attempt.scorePercent;
    }

    // 2. Persist latest attempt details
    final updatedAttempts = Map<String, QuizAttemptModel>.from(current.lastQuizAttempts);
    updatedAttempts[attempt.unitId] = attempt;

    // 3. EXP Calculation:
    // Query stored maximum EXP for this quiz (checking quizId or unitId)
    final quizKey = attempt.quizId.isNotEmpty ? attempt.quizId : attempt.unitId;
    final prevMaxExp = current.quizHighestXp[quizKey] ?? current.quizHighestXp[attempt.unitId] ?? 0;

    final attemptExp = ((attempt.scorePercent.clamp(0, 100) / 100.0) * quizTotalXp).round();
    final awardedExp = (attemptExp - prevMaxExp).clamp(0, quizTotalXp);

    final updatedQuizHighestXp = Map<String, int>.from(current.quizHighestXp);
    if (attemptExp > prevMaxExp) {
      updatedQuizHighestXp[quizKey] = attemptExp;
      updatedQuizHighestXp[attempt.unitId] = attemptExp;
    }

    final updated = current.copyWith(
      unitQuizScores: updatedScores,
      lastQuizAttempts: updatedAttempts,
      quizHighestXp: updatedQuizHighestXp,
      totalXp: current.totalXp + awardedExp,
      lastActiveDate: DateTime.now().toIso8601String().substring(0, 10),
    );
    await saveProgress(updated);
    return awardedExp;
  }

  @override
  Future<void> awardPracticeXp(int earnedXp, {String? badgeId}) async {
    final current = await getProgress();
    final updatedBadges = Set<String>.from(current.unlockedBadges);
    if (badgeId != null && badgeId.isNotEmpty) {
      updatedBadges.add(badgeId);
    }
    final updated = current.copyWith(
      totalXp: current.totalXp + earnedXp,
      unlockedBadges: updatedBadges,
      lastActiveDate: DateTime.now().toIso8601String().substring(0, 10),
    );
    await saveProgress(updated);
  }

  @override
  Future<void> resetProgress() async {
    await _storageService.remove(_storageKey);
  }
}
