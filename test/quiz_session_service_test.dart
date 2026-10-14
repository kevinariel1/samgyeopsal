import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_korean/core/services/quiz_session_service.dart';
import 'package:learn_korean/data/models/quiz_attempt_model.dart';
import 'package:learn_korean/data/models/quiz_model.dart';

void main() {
  group('QuizSessionService - Randomization & Session Rotation', () {
    final sampleQuestions = List.generate(
      10,
      (i) => QuizQuestionModel(
        id: 'q_$i',
        type: QuestionType.multipleChoice,
        prompt: 'Question $i prompt',
        soundToPlay: 'sound_$i',
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 1,
        explanation: 'Explanation $i',
      ),
    );

    final fullBank = QuizModel(
      id: 'quiz_1',
      unitId: 'unit_1',
      passingScorePercent: 80,
      questions: sampleQuestions,
    );

    test('First-time user: samples requested session size without repetition', () {
      final session = QuizSessionService.generateRetakeSession(
        quizBank: fullBank,
        previousAttempt: null,
        sessionLength: 5,
        random: Random(42),
      );

      expect(session.questions.length, equals(5));
      // No duplicate question IDs
      final idSet = session.questions.map((q) => q.id).toSet();
      expect(idSet.length, equals(5));
      for (final q in session.questions) {
        expect(fullBank.questions.map((e) => e.id), contains(q.id));
      }
    });

    test('Retake mode: excludes questions seen in previous attempt when bank is sufficiently large', () {
      // User previously took questions q_0, q_1, q_2, q_3, q_4
      final previousAttempt = QuizAttemptModel(
        unitId: 'unit_1',
        quizId: 'quiz_1',
        scorePercent: 100,
        completedAt: '2026-10-14T10:00:00Z',
        questionIds: ['q_0', 'q_1', 'q_2', 'q_3', 'q_4'],
        selectedOptionIndices: {
          'q_0': 1,
          'q_1': 1,
          'q_2': 1,
          'q_3': 1,
          'q_4': 1,
        },
      );

      // Generate a new session with sessionLength 5
      final session = QuizSessionService.generateRetakeSession(
        quizBank: fullBank,
        previousAttempt: previousAttempt,
        sessionLength: 5,
        random: Random(100),
      );

      expect(session.questions.length, equals(5));
      final generatedIds = session.questions.map((q) => q.id).toSet();

      // None of the previously seen questions should be in the new session!
      for (final prevId in previousAttempt.questionIds) {
        expect(generatedIds.contains(prevId), isFalse,
            reason: 'Question $prevId should have been excluded in retake rotation');
      }
      expect(generatedIds, equals({'q_5', 'q_6', 'q_7', 'q_8', 'q_9'}));
    });

    test('Retake mode: backfills and prioritizes missed questions when unseen pool is small', () {
      // Bank has 6 questions total: q_0 to q_5
      final smallBank = QuizModel(
        id: 'quiz_small',
        unitId: 'unit_1',
        passingScorePercent: 80,
        questions: sampleQuestions.take(6).toList(),
      );

      // Previous attempt saw q_0, q_1, q_2, q_3, q_4 (5 questions)
      // User got q_0 WRONG, but got q_1, q_2, q_3, q_4 correct.
      // Unseen question is only q_5 (1 question).
      final previousAttempt = QuizAttemptModel(
        unitId: 'unit_1',
        quizId: 'quiz_small',
        scorePercent: 80,
        completedAt: '2026-10-14T10:00:00Z',
        questionIds: ['q_0', 'q_1', 'q_2', 'q_3', 'q_4'],
        selectedOptionIndices: {
          'q_0': 0, // incorrect (correctIndex is 1)
          'q_1': 1,
          'q_2': 1,
          'q_3': 1,
          'q_4': 1,
        },
      );

      // We request sessionLength of 2:
      // It should pick q_5 (unseen) and the 1 backfill question MUST be q_0 (the missed question)!
      final session = QuizSessionService.generateRetakeSession(
        quizBank: smallBank,
        previousAttempt: previousAttempt,
        sessionLength: 2,
        random: Random(7),
      );

      expect(session.questions.length, equals(2));
      final generatedIds = session.questions.map((q) => q.id).toSet();
      expect(generatedIds, contains('q_5')); // Unseen question
      expect(generatedIds, contains('q_0')); // Missed question prioritized for reinforcement
    });

    test('Edge case: Small question bank where total questions <= session size', () {
      final tinyBank = QuizModel(
        id: 'quiz_tiny',
        unitId: 'unit_1',
        passingScorePercent: 80,
        questions: sampleQuestions.take(3).toList(),
      );

      // Request 5 questions from a bank of 3
      final session = QuizSessionService.generateRetakeSession(
        quizBank: tinyBank,
        previousAttempt: null,
        sessionLength: 5,
      );

      // Clamps cleanly to 3 without throwing RangeError
      expect(session.questions.length, equals(3));
      final idSet = session.questions.map((q) => q.id).toSet();
      expect(idSet, equals({'q_0', 'q_1', 'q_2'}));
    });

    test('Review mode: Reconstructs exact sequence and order of questions without reshuffling', () {
      final previousAttempt = QuizAttemptModel(
        unitId: 'unit_1',
        quizId: 'quiz_1',
        scorePercent: 60,
        completedAt: '2026-10-14T11:00:00Z',
        questionIds: ['q_7', 'q_2', 'q_9', 'q_0', 'q_4'],
        selectedOptionIndices: {
          'q_7': 1,
          'q_2': 0,
          'q_9': 1,
          'q_0': 2,
          'q_4': 1,
        },
      );

      final reviewSession = QuizSessionService.reconstructReviewSession(
        quizBank: fullBank,
        previousAttempt: previousAttempt,
      );

      expect(reviewSession.questions.length, equals(5));
      expect(
        reviewSession.questions.map((q) => q.id).toList(),
        equals(['q_7', 'q_2', 'q_9', 'q_0', 'q_4']),
        reason: 'Review mode must maintain the exact order from the user session',
      );
    });
  });
}
