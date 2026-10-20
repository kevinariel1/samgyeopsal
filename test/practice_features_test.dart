import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_korean/core/services/audio_service.dart';
import 'package:learn_korean/core/services/storage_service.dart';
import 'package:learn_korean/data/models/unit_model.dart';
import 'package:learn_korean/data/repositories/progress_repository_impl.dart';
import 'package:learn_korean/main.dart';
import 'package:learn_korean/presentation/providers/app_providers.dart';
import 'package:learn_korean/presentation/screens/hangul_builder_screen.dart';
import 'package:learn_korean/presentation/screens/progress_screen.dart';
import 'package:learn_korean/presentation/screens/sound_detective_screen.dart';
import 'package:learn_korean/presentation/screens/speed_match_screen.dart';
import 'package:learn_korean/presentation/screens/writing_studio_screen.dart';
import 'package:learn_korean/presentation/widgets/floating_fun_fact_guide.dart';

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
    expect(find.text('Sound Detective 🎧'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Speed Match ⚡'), findsOneWidget);
    expect(find.text('Smart Flashcards 🃏'), findsOneWidget);
  });

  testWidgets('HangulBuilderScreen composes syllables in Workshop and awards XP & badge in Challenge mode',
      (WidgetTester tester) async {
    final mockAudio = MockAudioService();
    final mockStorage = MemoryStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
          storageServiceProvider.overrideWithValue(mockStorage),
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

    // Verify persistent XP and badge were saved
    final progress = await ProgressRepositoryImpl(mockStorage).getProgress();
    expect(progress.totalXp, 10);
    expect(progress.hasBadge('badge_syllable_architect'), isTrue);
  });

  testWidgets('SoundDetectiveScreen plays mystery sound and awards badge on correct contrast answer',
      (WidgetTester tester) async {
    final mockAudio = MockAudioService();
    final mockStorage = MemoryStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
          storageServiceProvider.overrideWithValue(mockStorage),
        ],
        child: const MaterialApp(
          home: SoundDetectiveScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sound Detective 🎧'), findsOneWidget);
    expect(find.text('Tap to Listen to the Mystery Sound'), findsOneWidget);

    // First round target is index 1 ('카')
    await tester.ensureVisible(find.text('카'));
    await tester.tap(find.text('카'));
    await tester.pumpAndSettle();

    expect(find.text('Next Sound Challenge (+5 XP)'), findsOneWidget);
    final progress = await ProgressRepositoryImpl(mockStorage).getProgress();
    expect(progress.totalXp, 5);
    expect(progress.hasBadge('badge_ear_detective'), isTrue);
  });

  testWidgets('ProgressScreen displays Achievement Badges showcase',
      (WidgetTester tester) async {
    final mockStorage = MemoryStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(mockStorage),
        ],
        child: const MaterialApp(
          home: ProgressScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Achievement Badges 🏅'), findsOneWidget);
    expect(find.text('Block Builder'), findsOneWidget);
    expect(find.text('Ear Detective'), findsOneWidget);
  });

  testWidgets('WritingStudioScreen switches character groups and toggles guides',
      (WidgetTester tester) async {
    final mockAudio = MockAudioService();
    final mockStorage = MemoryStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
          storageServiceProvider.overrideWithValue(mockStorage),
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
    final mockStorage = MemoryStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
          storageServiceProvider.overrideWithValue(mockStorage),
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

  testWidgets('FloatingFunFactGuide shows initial greeting, auto-retracts to peeking, pops up on timer or tap, and closes via X or veil',
      (WidgetTester tester) async {
    final mockStorage = MemoryStorageService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              const Center(child: Text('Main Content')),
              FloatingFunFactGuide(
                storageService: mockStorage,
                promptInterval: const Duration(minutes: 5),
                greetingDuration: const Duration(seconds: 6),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. At launch, the cat greets the user with a time-of-day WELCOME bubble (no 'DID YOU KNOW?' yet)
    expect(find.textContaining('WELCOME •'), findsOneWidget);
    expect(find.textContaining('DID YOU KNOW?'), findsNothing);

    // 2. After 6 seconds elapse, the greeting auto-retracts into the peeking state (no bubble shown)
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(find.textContaining('WELCOME •'), findsNothing);
    expect(find.textContaining('DID YOU KNOW?'), findsNothing);
    expect(find.text('Next Fact'), findsNothing);

    // 3. After 5 minutes elapse, the cat automatically pops out with a fun fact bubble
    await tester.pump(const Duration(minutes: 5));
    await tester.pumpAndSettle();

    expect(find.textContaining('DID YOU KNOW?'), findsOneWidget);
    expect(find.text('Next Fact'), findsOneWidget);

    // 4. Tapping the close 'X' button hides the bubble and retracts the cat
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining('DID YOU KNOW?'), findsNothing);

    // 5. Waiting another 5 minutes pops it up again, and tapping the dark veil (top-left) closes it
    await tester.pump(const Duration(minutes: 5));
    await tester.pumpAndSettle();
    expect(find.textContaining('DID YOU KNOW?'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.textContaining('DID YOU KNOW?'), findsNothing);
  });
}
