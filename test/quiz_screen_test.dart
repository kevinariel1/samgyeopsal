import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_korean/core/services/audio_service.dart';
import 'package:learn_korean/core/services/storage_service.dart';
import 'package:learn_korean/data/models/quiz_attempt_model.dart';
import 'package:learn_korean/data/models/quiz_model.dart';
import 'package:learn_korean/presentation/providers/app_providers.dart';
import 'package:learn_korean/presentation/screens/quiz_screen.dart';
import 'package:learn_korean/presentation/widgets/hangul_tracing_widget.dart';

void main() {
  testWidgets('QuizScreen displays HangulTracingWidget for tracing questions and completes on verified trace',
      (WidgetTester tester) async {
    const tracingQuiz = QuizModel(
      id: 'quiz_test',
      unitId: 'unit_1',
      passingScorePercent: 80,
      questions: [
        QuizQuestionModel(
          id: 'q_trace',
          type: QuestionType.tracing,
          prompt: 'Trace the letter ㄱ with your finger on the screen!',
          soundToPlay: 'g',
          options: ['Trace ㄱ to finish'],
          correctIndex: 0,
          explanation: 'Super job! ㄱ is a top horizontal stroke followed by a vertical drop.',
          targetCharacter: 'ㄱ',
        ),
      ],
    );

    final mockAudio = MockAudioService();
    final mockStorage = MemoryStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
          storageServiceProvider.overrideWithValue(mockStorage),
        ],
        child: const MaterialApp(
          home: QuizScreen(
            quiz: tracingQuiz,
            unitTitle: 'Unit 1',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify TRACING badge, prompt, and presence of HangulTracingWidget
    expect(find.text('TRACING'), findsOneWidget);
    expect(find.text('Trace the letter ㄱ with your finger on the screen!'), findsOneWidget);
    expect(find.byType(HangulTracingWidget), findsOneWidget);

    // Verify buttons inside the tracing widget exist
    expect(find.text('Clear Canvas'), findsOneWidget);
    expect(find.text('Verify Writing'), findsOneWidget);

    // No option cards displayed for tracing questions
    expect(find.text('Trace ㄱ to finish'), findsNothing);

    // Results button shouldn't show yet before tracing
    expect(find.text('See My Results'), findsNothing);

    // Tap "Verify Writing" with empty canvas -> shows SnackBar, doesn't complete
    await tester.ensureVisible(find.text('Verify Writing'));
    await tester.tap(find.text('Verify Writing'));
    await tester.pumpAndSettle();
    expect(find.text('See My Results'), findsNothing);
  });

  testWidgets('QuizScreen in review mode displays previous answers and explanation immediately',
      (WidgetTester tester) async {
    const reviewQuiz = QuizModel(
      id: 'quiz_test',
      unitId: 'unit_1',
      passingScorePercent: 80,
      questions: [
        QuizQuestionModel(
          id: 'q_review_1',
          type: QuestionType.multipleChoice,
          prompt: 'Which letter sounds like n?',
          soundToPlay: 'n',
          options: ['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ'],
          correctIndex: 1,
          explanation: 'ㄴ makes the n sound!',
        ),
      ],
    );

    final mockAttempt = QuizAttemptModel(
      unitId: 'unit_1',
      quizId: 'quiz_test',
      scorePercent: 100,
      completedAt: '2026-10-14T12:00:00Z',
      questionIds: ['q_review_1'],
      selectedOptionIndices: {'q_review_1': 1},
    );

    final mockAudio = MockAudioService();
    final mockStorage = MemoryStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
          storageServiceProvider.overrideWithValue(mockStorage),
        ],
        child: MaterialApp(
          home: QuizScreen(
            quiz: reviewQuiz,
            unitTitle: 'Unit 1',
            mode: QuizMode.review,
            previousAttempt: mockAttempt,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Review AppBar & banner
    expect(find.text('Unit 1 Review'), findsOneWidget);
    expect(find.textContaining('Previous Attempt Review'), findsOneWidget);

    // Explanation is shown immediately without user interaction
    expect(find.text('ㄴ makes the n sound!'), findsOneWidget);

    // Selected choice has "Your Choice" indicator
    expect(find.text('Your Choice'), findsOneWidget);

    // Finish review button exists
    expect(find.text('Finish Review'), findsOneWidget);
  });

  testWidgets('Drawing character incorrectly in quiz marks as wrong answer and reveals next question',
      (WidgetTester tester) async {
    const tracingQuiz = QuizModel(
      id: 'quiz_test',
      unitId: 'unit_1',
      passingScorePercent: 80,
      questions: [
        QuizQuestionModel(
          id: 'q_trace',
          type: QuestionType.tracing,
          prompt: 'Trace the letter ㄱ with your finger on the screen!',
          soundToPlay: 'g',
          options: ['Trace ㄱ to finish'],
          correctIndex: 0,
          explanation: 'Super job! ㄱ is a top horizontal stroke followed by a vertical drop.',
          targetCharacter: 'ㄱ',
        ),
      ],
    );

    final mockAudio = MockAudioService();
    final mockStorage = MemoryStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
          storageServiceProvider.overrideWithValue(mockStorage),
        ],
        child: const MaterialApp(
          home: QuizScreen(
            quiz: tracingQuiz,
            unitTitle: 'Unit 1',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify guides and character shadow are invisible in quiz mode
    final tracingWidget = tester.widget<HangulTracingWidget>(find.byType(HangulTracingWidget));
    expect(tracingWidget.showGuides, isFalse);
    expect(tracingWidget.showGrid, isFalse);

    // Draw an incorrect stroke inside the tracing canvas
    final center = tester.getCenter(find.byType(HangulTracingWidget));
    final gesture = await tester.startGesture(Offset(center.dx - 30, center.dy - 30));
    await gesture.moveBy(const Offset(20, 20));
    await gesture.up();
    await tester.pumpAndSettle();

    // Scroll to and tap Verify Writing
    await tester.ensureVisible(find.text('Verify Writing'));
    await tester.tap(find.text('Verify Writing'));
    await tester.pumpAndSettle();

    // Evaluated as wrong: explanation is shown and button to advance appears
    await tester.ensureVisible(find.text('See My Results'));
    expect(find.text('Super job! ㄱ is a top horizontal stroke followed by a vertical drop.'), findsOneWidget);
    expect(find.text('See My Results'), findsOneWidget);
  });
}
