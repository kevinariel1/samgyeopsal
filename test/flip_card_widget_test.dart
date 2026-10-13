import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_korean/core/services/audio_service.dart';
import 'package:learn_korean/data/models/card_model.dart';
import 'package:learn_korean/presentation/providers/app_providers.dart';
import 'package:learn_korean/presentation/widgets/flip_card_widget.dart';

void main() {
  testWidgets('FlipCardWidget displays character and flips to show mnemonic',
      (WidgetTester tester) async {
    const testCard = CardModel(
      id: 'card_g',
      korean: 'ㄱ',
      romanization: 'g / k',
      meaning: 'Corner shape',
      sound: 'g',
      mnemonic: 'Looks like an elbow or a corner.',
      exampleWord: '고양이 (Cat)',
      iconName: 'pets',
    );

    final mockAudio = MockAudioService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          audioServiceProvider.overrideWithValue(mockAudio),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: FlipCardWidget(card: testCard),
            ),
          ),
        ),
      ),
    );

    // Initial front state
    expect(find.text('ㄱ'), findsOneWidget);
    expect(find.text('Sounds like: "g / k"'), findsOneWidget);
    expect(find.text('Tap card to see the baby story!'), findsOneWidget);

    // Tap to flip card
    await tester.tap(find.byType(FlipCardWidget));
    await tester.pumpAndSettle();

    // Back state revealed
    expect(find.text('Memory Hook (Mnemonic)'), findsOneWidget);
    expect(find.text('Looks like an elbow or a corner.'), findsOneWidget);
    expect(find.text('고양이 (Cat)'), findsOneWidget);
  });
}
