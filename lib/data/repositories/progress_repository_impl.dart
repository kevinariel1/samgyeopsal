import '../../core/services/storage_service.dart';
import '../../domain/repositories/progress_repository.dart';
import '../models/quiz_attempt_model.dart';
import '../models/user_progress_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  /// Updates streak and records active date using local device timezone boundaries.
  /// If today was already recorded: maintains current streak.
  /// If yesterday was the last active date: increments streak.
  /// If more than 1 day was missed: resets streak to 1.
  UserProgressModel _applyDailyStreak(UserProgressModel current, {DateTime? now}) {
    final localNow = (now ?? DateTime.now()).toLocal();
    final todayStr = localNow.toIso8601String().substring(0, 10);
    final lastStr = current.lastActiveDate;

    if (lastStr == todayStr) {
      final dates = Set<String>.from(current.activeDates)..add(todayStr);
      final sortedDates = dates.toList()..sort();
      return current.copyWith(
        lastActiveDate: todayStr,
        activeDates: sortedDates,
      );
    }

    final todayDate = DateTime(localNow.year, localNow.month, localNow.day);
    DateTime? lastDate;
    try {
      final parts = lastStr.split('-');
      if (parts.length == 3) {
        lastDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      }
    } catch (_) {}

    int newStreak;
    if (lastDate == null) {
      newStreak = 1;
    } else {
      final diffDays = todayDate.difference(lastDate).inDays;
      if (diffDays == 1) {
        newStreak = current.streakDays + 1;
      } else if (diffDays <= 0) {
        newStreak = current.streakDays;
      } else {
        newStreak = 1; // Missed day resets streak
      }
    }

    final newLongest = newStreak > current.longestStreak ? newStreak : current.longestStreak;
    final dates = Set<String>.from(current.activeDates)..add(todayStr);
    final sortedDates = dates.toList()..sort();

    return current.copyWith(
      streakDays: newStreak,
      longestStreak: newLongest,
      activeDates: sortedDates,
      lastActiveDate: todayStr,
    );
  }

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
    final withStreak = _applyDailyStreak(current);
    final updated = withStreak.copyWith(
      completedLessonIds: updatedLessons,
      totalXp: withStreak.totalXp + earnedXp,
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

    final withStreak = _applyDailyStreak(current);
    final updated = withStreak.copyWith(
      unitQuizScores: updatedScores,
      quizHighestXp: updatedQuizHighestXp,
      totalXp: withStreak.totalXp + awardedExp,
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

    final withStreak = _applyDailyStreak(current);
    final updated = withStreak.copyWith(
      unitQuizScores: updatedScores,
      lastQuizAttempts: updatedAttempts,
      quizHighestXp: updatedQuizHighestXp,
      totalXp: withStreak.totalXp + awardedExp,
    );
    await saveProgress(updated);
    return awardedExp;
  }

  @override
  Future<void> awardPracticeXp(int earnedXp, {String? badgeId}) async {
    final current = await getProgress();
    final withStreak = _applyDailyStreak(current);
    final updatedBadges = Set<String>.from(withStreak.unlockedBadges);
    if (badgeId != null && badgeId.isNotEmpty) {
      updatedBadges.add(badgeId);
    }
    final updated = withStreak.copyWith(
      totalXp: withStreak.totalXp + earnedXp,
      unlockedBadges: updatedBadges,
    );
    await saveProgress(updated);
  }

  @override
  Future<void> resetProgress() async {
    await _storageService.remove(_storageKey);
  }
}
