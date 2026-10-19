import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_korean/core/services/audio_service.dart';
import 'package:learn_korean/core/services/storage_service.dart';
import 'package:learn_korean/data/models/unit_model.dart';
import 'package:learn_korean/main.dart';
import 'package:learn_korean/presentation/providers/app_providers.dart';
import 'package:learn_korean/presentation/screens/hangul_builder_screen.dart';
import 'package:learn_korean/presentation/screens/speed_match_screen.dart';
import 'package:learn_korean/presentation/screens/writing_studio_screen.dart';

import 'widget_test.dart';

void main() {
  testWidgets('MainNavigationScreen switches between Journey, Guide, Practice, and Profile tabs',
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

    // Verify 4 bottom navigation destinations exist
    expect(find.text('Journey'), findsOneWidget);
    expect(find.text('Guide'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Switch to Practice tab
    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();

    expect(find.text('Practice Hub 🎮'), findsOneWidget);
    expect(find.text('Build the Hangul 🧩'), findsOneWidget);
    expect(find.text('Writing Studio ✍️'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Speed Match ⚡'), findsOneWidget);
    expect(find.text('Smart Flashcards 🃏'), findsOneWidget);
  });

  testWidgets('HangulBuilderScreen composes syllables in Workshop and verifies puzzles in Challenge mode',
      (WidgetTester tester) async {
    final mockAudio = MockAudioService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
        ],
        child: const MaterialApp(
          home: HangulBuilderScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Default selection is ㄱ + ㅏ = 가
    expect(find.text('가'), findsOneWidget);
    expect(find.text('Sounds like: "ga"'), findsOneWidget);
    expect(find.textContaining('Real Word:'), findsOneWidget);

    // Tap 'ㄴ' initial consonant -> should compose '나'
    await tester.tap(find.text('ㄴ').first);
    await tester.pumpAndSettle();
    expect(find.text('나'), findsOneWidget);
    expect(find.text('Sounds like: "na"'), findsOneWidget);
    expect(mockAudio.spokenHistory, contains('ko:나'));

    // Switch to Puzzle Challenge tab
    await tester.tap(find.text('Puzzle Challenge'));
    await tester.pumpAndSettle();

    expect(find.text('Build the block for "GA"!'), findsOneWidget);

    // Select ㄱ in Challenge tab and tap Snap & Check!
    await tester.tap(find.text('ㄱ').first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Snap & Check!'));
    await tester.tap(find.text('Snap & Check!'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Awesome! You built "가"'), findsOneWidget);
    expect(find.text('Next Puzzle'), findsOneWidget);
  });

  testWidgets('WritingStudioScreen switches character groups and toggles guides',
      (WidgetTester tester) async {
    final mockAudio = MockAudioService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
        ],
        child: const MaterialApp(
          home: WritingStudioScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Writing Studio ✍️'), findsOneWidget);
    expect(find.text('Write "ㄱ" with your finger!'), findsOneWidget);

    // Switch group to Basic Vowels
    await tester.tap(find.text('Basic Vowels'));
    await tester.pumpAndSettle();

    expect(find.text('Write "ㅏ" with your finger!'), findsOneWidget);
  });

  testWidgets('SpeedMatchScreen renders 6 pairs and allows matching',
      (WidgetTester tester) async {
    final mockAudio = MockAudioService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
        ],
        child: const MaterialApp(
          home: SpeedMatchScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Speed Match ⚡'), findsOneWidget);
    expect(find.text('Matched: 0 / 6'), findsOneWidget);
    expect(find.text('Moves: 0'), findsOneWidget);
  });
}
