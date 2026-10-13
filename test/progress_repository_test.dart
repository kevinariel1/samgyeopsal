import 'package:flutter_test/flutter_test.dart';
import 'package:learn_korean/core/services/storage_service.dart';
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
  });
}
