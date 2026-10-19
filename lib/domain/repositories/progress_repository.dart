import '../../data/models/quiz_attempt_model.dart';
import '../../data/models/user_progress_model.dart';

abstract class ProgressRepository {
  Future<UserProgressModel> getProgress();
  Future<void> saveProgress(UserProgressModel progress);
  Future<void> markLessonComplete(String lessonId, {int earnedXp = 20});
  Future<int> recordQuizResult(String unitId, int scorePercent, {int totalQuizXp = 100, int? earnedXp});
  Future<int> recordQuizAttempt(QuizAttemptModel attempt, {int totalQuizXp = 100, int? earnedXp});
  Future<void> awardPracticeXp(int earnedXp, {String? badgeId});
  Future<void> resetProgress();
}

