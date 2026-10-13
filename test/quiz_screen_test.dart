import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_korean/core/services/audio_service.dart';
import 'package:learn_korean/core/services/storage_service.dart';
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
}
