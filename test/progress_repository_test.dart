import 'package:flutter_test/flutter_test.dart';
import 'package:learn_korean/core/services/storage_service.dart';
import 'package:learn_korean/data/models/quiz_attempt_model.dart';
import 'package:learn_korean/data/models/unit_model.dart';
import 'package:learn_korean/data/models/user_progress_model.dart';
import 'package:learn_korean/data/repositories/progress_repository_impl.dart';

void main() {
  group('UserProgressModel Logic', () {
    test('Unit 1 is always unlocked by default', () {
      final progress = UserProgressModel.initial();
      const unit1 = UnitModel(
        id: 'unit_1',
        title: 'Unit 1',
        subtitle: 'Sub',
        description: 'Desc',
        order: 1,
        unlockRequirement: 0,
        lessons: [],
      );

      expect(progress.isUnitUnlocked(unit1, [unit1]), isTrue);
    });

    test('Unit 2 stays locked if Unit 1 quiz is below 80%', () {
      final progress = UserProgressModel.initial().copyWith(
        unitQuizScores: {'unit_1': 60},
      );
      const unit1 = UnitModel(
        id: 'unit_1',
        title: 'Unit 1',
        subtitle: 'Sub',
        description: 'Desc',
        order: 1,
        unlockRequirement: 0,
        lessons: [],
      );
      const unit2 = UnitModel(
        id: 'unit_2',
        title: 'Unit 2',
        subtitle: 'Sub',
        description: 'Desc',
        order: 2,
        unlockRequirement: 80,
        lessons: [],
      );

      expect(progress.isUnitUnlocked(unit2, [unit1, unit2]), isFalse);
    });

    test('Unit 2 unlocks when Unit 1 quiz achieves 80% mastery gate', () {
      final progress = UserProgressModel.initial().copyWith(
        unitQuizScores: {'unit_1': 80},
      );
      const unit1 = UnitModel(
        id: 'unit_1',
        title: 'Unit 1',
        subtitle: 'Sub',
        description: 'Desc',
        order: 1,
        unlockRequirement: 0,
        lessons: [],
      );
      const unit2 = UnitModel(
        id: 'unit_2',
        title: 'Unit 2',
        subtitle: 'Sub',
        description: 'Desc',
        order: 2,
        unlockRequirement: 80,
        lessons: [],
      );

      expect(progress.isUnitUnlocked(unit2, [unit1, unit2]), isTrue);
    });

    test('Overall accuracy computes average correctly', () {
      final progress = UserProgressModel.initial().copyWith(
        unitQuizScores: {'unit_1': 100, 'unit_2': 80},
      );

      expect(progress.overallAccuracy, equals(90.0));
      expect(progress.passedUnitsCount, equals(2));
    });
  });

  group('ProgressRepositoryImpl with MemoryStorage', () {
    late MemoryStorageService storage;
    late ProgressRepositoryImpl repository;

    setUp(() {
      storage = MemoryStorageService();
      repository = ProgressRepositoryImpl(storage);
    });

    test('Starts with empty initial progress', () async {
      final p = await repository.getProgress();
      expect(p.completedLessonIds, isEmpty);
      expect(p.totalXp, equals(0));
    });

    test('Completing a lesson marks it done and adds XP', () async {
      await repository.markLessonComplete('lesson_1_1', earnedXp: 20);
      final p = await repository.getProgress();

      expect(p.isLessonCompleted('lesson_1_1'), isTrue);
      expect(p.totalXp, equals(20));
    });

    test('Recording quiz result persists highest score', () async {
      await repository.recordQuizResult('unit_1', 70);
      var p = await repository.getProgress();
      expect(p.unitQuizScores['unit_1'], equals(70));

      // Attempt lower score should not overwrite
      await repository.recordQuizResult('unit_1', 60);
      p = await repository.getProgress();
      expect(p.unitQuizScores['unit_1'], equals(70));

      // Higher score overwrites
      await repository.recordQuizResult('unit_1', 90);
      p = await repository.getProgress();
      expect(p.unitQuizScores['unit_1'], equals(90));
    });

    test('Recording quiz attempt persists attempt details and score', () async {
      final attempt = QuizAttemptModel(
        unitId: 'unit_1',
        quizId: 'quiz_unit_1',
        scorePercent: 80,
        completedAt: '2026-10-14T12:00:00Z',
        questionIds: ['q1', 'q2', 'q3'],
        selectedOptionIndices: {'q1': 1, 'q2': 2, 'q3': 0},
      );

      await repository.recordQuizAttempt(attempt);
      final p = await repository.getProgress();

      expect(p.unitQuizScores['unit_1'], equals(80));
      expect(p.lastQuizAttempts['unit_1'], isNotNull);
      final savedAttempt = p.getLastAttempt('unit_1')!;
      expect(savedAttempt.scorePercent, equals(80));
      expect(savedAttempt.questionIds, equals(['q1', 'q2', 'q3']));
      expect(savedAttempt.selectedOptionIndices['q1'], equals(1));
    });

    group('Quiz EXP Rules (Non-Duplicating Delta Progression)', () {
      test('Rule 1: First attempt at 80% earns 80 EXP on a 100 EXP quiz', () async {
        final awarded = await repository.recordQuizResult('unit_1', 80, totalQuizXp: 100);
        final p = await repository.getProgress();

        expect(awarded, equals(80));
        expect(p.totalXp, equals(80));
        expect(p.getQuizHighestXp('unit_1'), equals(80));
      });

      test('Rule 2: Retake to 100% after 80% earns only the remaining 20 EXP (total 100 EXP)', () async {
        // Attempt 1: 80%
        final firstAward = await repository.recordQuizResult('unit_1', 80, totalQuizXp: 100);
        expect(firstAward, equals(80));

        // Attempt 2 (Retake): 100%
        final retakeAward = await repository.recordQuizResult('unit_1', 100, totalQuizXp: 100);
        final p = await repository.getProgress();

        expect(retakeAward, equals(20), reason: 'Only the unclaimed 20 EXP should be awarded');
        expect(p.totalXp, equals(100), reason: 'Total EXP across all attempts must equal 100');
        expect(p.getQuizHighestXp('unit_1'), equals(100));
      });

      test('Rule 3: Retake after 100% perfect score awards 0 additional EXP', () async {
        // First get 100%
        await repository.recordQuizResult('unit_1', 100, totalQuizXp: 100);
        var p = await repository.getProgress();
        expect(p.totalXp, equals(100));

        // Retake with 100% again
        final retakeAward = await repository.recordQuizResult('unit_1', 100, totalQuizXp: 100);
        p = await repository.getProgress();

        expect(retakeAward, equals(0), reason: 'No new EXP should be awarded after 100%');
        expect(p.totalXp, equals(100));
        expect(p.getQuizHighestXp('unit_1'), equals(100));
      });

      test('Rule 4: Lower retake after 100% (e.g. 80%) awards 0 EXP and does NOT reduce EXP', () async {
        // First achieve 100%
        await repository.recordQuizResult('unit_1', 100, totalQuizXp: 100);

        // Later attempt scores lower (80%)
        final lowerRetakeAward = await repository.recordQuizResult('unit_1', 80, totalQuizXp: 100);
        final p = await repository.getProgress();

        expect(lowerRetakeAward, equals(0));
        expect(p.totalXp, equals(100), reason: 'Total XP must not be reduced');
        expect(p.getQuizHighestXp('unit_1'), equals(100), reason: 'Stored highest quiz EXP stays at 100');
        expect(p.unitQuizScores['unit_1'], equals(100), reason: 'Best score remains 100');
      });

      test('Lower retake after partial score (80% -> 60%) awards 0 EXP and does not drop', () async {
        // Attempt 1: 80%
        await repository.recordQuizResult('unit_1', 80, totalQuizXp: 100);

        // Attempt 2: 60%
        final award = await repository.recordQuizResult('unit_1', 60, totalQuizXp: 100);
        final p = await repository.getProgress();

        expect(award, equals(0));
        expect(p.totalXp, equals(80));
        expect(p.getQuizHighestXp('unit_1'), equals(80));
      });

      test('Multi-step progression: 50% -> 70% -> 90% -> 100% correctly increments to 100 EXP total', () async {
        // Step 1: 50%
        expect(await repository.recordQuizResult('unit_1', 50, totalQuizXp: 100), equals(50));
        // Step 2: 70% (+20)
        expect(await repository.recordQuizResult('unit_1', 70, totalQuizXp: 100), equals(20));
        // Step 3: 90% (+20)
        expect(await repository.recordQuizResult('unit_1', 90, totalQuizXp: 100), equals(20));
        // Step 4: 100% (+10)
        expect(await repository.recordQuizResult('unit_1', 100, totalQuizXp: 100), equals(10));

        final p = await repository.getProgress();
        expect(p.totalXp, equals(100));
        expect(p.getQuizHighestXp('unit_1'), equals(100));
      });

      test('QuizAttemptModel flow respects non-duplication rules', () async {
        QuizAttemptModel makeAttempt(int score) => QuizAttemptModel(
              unitId: 'unit_1',
              quizId: 'quiz_1',
              scorePercent: score,
              completedAt: DateTime.now().toIso8601String(),
              questionIds: ['q1'],
              selectedOptionIndices: {'q1': 0},
            );

        // First attempt 80%
        final award1 = await repository.recordQuizAttempt(makeAttempt(80), totalQuizXp: 100);
        expect(award1, equals(80));

        // Retake 100%
        final award2 = await repository.recordQuizAttempt(makeAttempt(100), totalQuizXp: 100);
        expect(award2, equals(20));

        // Retake again 100%
        final award3 = await repository.recordQuizAttempt(makeAttempt(100), totalQuizXp: 100);
        expect(award3, equals(0));

        // Retake lower 80%
        final award4 = await repository.recordQuizAttempt(makeAttempt(80), totalQuizXp: 100);
        expect(award4, equals(0));

        final p = await repository.getProgress();
        expect(p.totalXp, equals(100));
        expect(p.getQuizHighestXp('quiz_1'), equals(100));
        expect(p.getQuizHighestXp('unit_1'), equals(100));
      });
    });
  });
}
