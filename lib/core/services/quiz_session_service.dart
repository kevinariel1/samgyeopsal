import 'dart:math';
import '../../data/models/quiz_attempt_model.dart';
import '../../data/models/quiz_model.dart';

/// Service responsible for quiz session generation, question bank rotation,
/// spaced-retrieval deprioritization, and past attempt reconstruction.
class QuizSessionService {
  static const int defaultSessionLength = 5;

  /// Generates a randomized, rotated quiz session from the [quizBank].
  ///
  /// - If [previousAttempt] is null (first attempt), samples randomly without replacement.
  /// - If [previousAttempt] is present (retake mode), prioritizes unseen questions.
  ///   If the unseen pool is smaller than [sessionLength], backfills from recently
  ///   seen questions, prioritizing questions previously answered incorrectly.
  /// - Clamps [sessionLength] to the total questions available in the bank.
  static QuizModel generateRetakeSession({
    required QuizModel quizBank,
    QuizAttemptModel? previousAttempt,
    int sessionLength = defaultSessionLength,
    Random? random,
  }) {
    final rng = random ?? Random();
    final allQuestions = List<QuizQuestionModel>.from(quizBank.questions);

    if (allQuestions.isEmpty) {
      return quizBank;
    }

    final targetCount = sessionLength.clamp(1, allQuestions.length);

    // Case 1: First-time quiz taker or no previous attempt recorded
    if (previousAttempt == null || previousAttempt.questionIds.isEmpty) {
      allQuestions.shuffle(rng);
      return QuizModel(
        id: quizBank.id,
        unitId: quizBank.unitId,
        passingScorePercent: quizBank.passingScorePercent,
        questions: allQuestions.take(targetCount).toList(),
      );
    }

    // Case 2: Retake with prior attempt history
    final prevIdSet = previousAttempt.questionIds.toSet();

    final unseenQuestions =
        allQuestions.where((q) => !prevIdSet.contains(q.id)).toList()..shuffle(rng);

    final seenQuestions =
        allQuestions.where((q) => prevIdSet.contains(q.id)).toList();

    List<QuizQuestionModel> selected;

    if (unseenQuestions.length >= targetCount) {
      // 100% fresh questions available
      selected = unseenQuestions.take(targetCount).toList();
    } else {
      // Unseen questions aren't enough to fill the session, backfill from seen pool
      selected = List<QuizQuestionModel>.from(unseenQuestions);
      final deficit = targetCount - selected.length;

      // Pedagogical prioritization within seen pool:
      // Prioritize questions the user missed in the last attempt for spaced retrieval.
      final missedQuestions = <QuizQuestionModel>[];
      final masteredQuestions = <QuizQuestionModel>[];

      for (final q in seenQuestions) {
        final selectedIdx = previousAttempt.selectedOptionIndices[q.id];
        if (selectedIdx == null || selectedIdx != q.correctIndex) {
          missedQuestions.add(q);
        } else {
          masteredQuestions.add(q);
        }
      }

      missedQuestions.shuffle(rng);
      masteredQuestions.shuffle(rng);

      final prioritizedBackfill = [...missedQuestions, ...masteredQuestions];
      selected.addAll(prioritizedBackfill.take(deficit));
    }

    // Shuffle the final selection so that new vs repeated questions appear in unpredictable order
    selected.shuffle(rng);

    return QuizModel(
      id: quizBank.id,
      unitId: quizBank.unitId,
      passingScorePercent: quizBank.passingScorePercent,
      questions: selected,
    );
  }

  /// Reconstructs the exact sequence of questions from a [previousAttempt] for review mode.
  ///
  /// Guarantees exact order and identity without reshuffling.
  static QuizModel reconstructReviewSession({
    required QuizModel quizBank,
    required QuizAttemptModel previousAttempt,
  }) {
    final questionMap = {for (final q in quizBank.questions) q.id: q};

    final reviewQuestions = <QuizQuestionModel>[];
    for (final id in previousAttempt.questionIds) {
      final question = questionMap[id];
      if (question != null) {
        reviewQuestions.add(question);
      }
    }

    return QuizModel(
      id: quizBank.id,
      unitId: quizBank.unitId,
      passingScorePercent: quizBank.passingScorePercent,
      questions: reviewQuestions.isNotEmpty ? reviewQuestions : quizBank.questions,
    );
  }
}
