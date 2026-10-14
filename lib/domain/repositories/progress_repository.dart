import '../../data/models/quiz_attempt_model.dart';
import '../../data/models/user_progress_model.dart';

abstract class ProgressRepository {
  Future<UserProgressModel> getProgress();
  Future<void> saveProgress(UserProgressModel progress);
  Future<void> markLessonComplete(String lessonId, {int earnedXp = 20});
  Future<void> recordQuizResult(String unitId, int scorePercent, {int earnedXp = 50});
  Future<void> recordQuizAttempt(QuizAttemptModel attempt, {int earnedXp = 50});
  Future<void> resetProgress();
}

