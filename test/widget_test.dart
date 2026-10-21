import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_korean/core/services/audio_service.dart';
import 'package:learn_korean/core/services/storage_service.dart';
import 'package:learn_korean/data/models/lesson_model.dart';
import 'package:learn_korean/data/models/unit_model.dart';
import 'package:learn_korean/domain/repositories/curriculum_repository.dart';
import 'package:learn_korean/main.dart';
import 'package:learn_korean/presentation/providers/app_providers.dart';

class FakeCurriculumRepository implements CurriculumRepository {
  final List<UnitModel> units;
  FakeCurriculumRepository(this.units);

  @override
  Future<List<UnitModel>> getAllUnits() async => units;

  @override
  Future<UnitModel?> getUnitById(String unitId) async =>
      units.where((u) => u.id == unitId).firstOrNull;

  @override
  Future<LessonModel?> getLessonById(String lessonId) async => null;
}

void main() {
  testWidgets('App launches and displays Hangul Baby home screen',
      (WidgetTester tester) async {
    const unit1 = UnitModel(
      id: 'unit_1',
      title: 'Unit 1: Basic Consonants',
      subtitle: 'Hangul Baby Steps',
      description: 'First steps in Korean',
      order: 1,
      unlockRequirement: 0,
      lessons: [],
    );

    final mockAudio = MockAudioService();
    final mockStorage = MemoryStorageService();
    final fakeCurriculum = FakeCurriculumRepository([unit1]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
          storageServiceProvider.overrideWithValue(mockStorage),
          curriculumRepositoryProvider.overrideWithValue(fakeCurriculum),
        ],
        child: const HangulBabyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hangul Baby'), findsOneWidget);
    expect(find.text('Hello Baby Learner!'), findsOneWidget);
    expect(find.text('Unit 1: Basic Consonants'), findsOneWidget);
  });
}
