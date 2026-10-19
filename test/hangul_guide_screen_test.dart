import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_korean/core/services/audio_service.dart';
import 'package:learn_korean/presentation/providers/app_providers.dart';
import 'package:learn_korean/presentation/screens/hangul_guide_screen.dart';

void main() {
  testWidgets('HangulGuideScreen displays tabs and plays audio when character tile is tapped',
      (WidgetTester tester) async {
    final mockAudio = MockAudioService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
        ],
        child: const MaterialApp(
          home: HangulGuideScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AppBar title and 3 tabs
    expect(find.text('Hangul Alphabet Guide'), findsOneWidget);
    expect(find.text('Consonants (19)'), findsOneWidget);
    expect(find.text('Vowels (21)'), findsOneWidget);
    expect(find.text('Syllables Matrix'), findsOneWidget);

    // Verify Consonants tab content
    expect(find.text('Basic Consonants (14)'), findsOneWidget);
    expect(find.text('ㄱ'), findsOneWidget);
    expect(find.text('g / k'), findsOneWidget);

    // Tap on character tile 'ㄱ' to trigger audio
    await tester.tap(find.text('ㄱ'));
    await tester.pumpAndSettle();
    expect(mockAudio.spokenHistory, contains('ko:그'));

    // Switch to Vowels Tab
    await tester.tap(find.text('Vowels (21)'));
    await tester.pumpAndSettle();

    expect(find.text('Basic Vowels (10)'), findsOneWidget);
    expect(find.text('ㅏ'), findsOneWidget);
    expect(find.text('a'), findsOneWidget);

    // Tap on 'ㅏ' to trigger audio
    await tester.tap(find.text('ㅏ'));
    await tester.pumpAndSettle();
    expect(mockAudio.spokenHistory, contains('ko:아'));

    // Switch to Syllables Matrix Tab
    await tester.tap(find.text('Syllables Matrix'));
    await tester.pumpAndSettle();

    // Verify presence of syllable matrix
    expect(find.text('가'), findsOneWidget);
    expect(find.text('나'), findsOneWidget);

    // Tap on syllable '가'
    await tester.tap(find.text('가'));
    await tester.pumpAndSettle();
    expect(mockAudio.spokenHistory, contains('ko:가'));
  });
}
