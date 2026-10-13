import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_korean/core/utils/hangul_stroke_evaluator.dart';

void main() {
  group('HangulStrokeEvaluator', () {
    const canvasSize = Size(300, 320);

    test('Rejects empty or too short strokes', () {
      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄱ',
        strokes: [
          [const Offset(100, 100)]
        ],
        canvasSize: canvasSize,
      );
      expect(res.isAccurate, isFalse);
      expect(res.feedbackMessage, contains('too short'));
    });

    test('Rejects completely wrong shape (e.g. circle or diagonal in wrong area)', () {
      // Drawing in bottom left where ㄱ has nothing
      final wrongStrokes = [
        List.generate(
          15,
          (i) => Offset(20.0 + i * 5, 250.0 + i * 2), // bottom-left region
        ),
      ];

      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄱ',
        strokes: wrongStrokes,
        canvasSize: canvasSize,
      );
      expect(res.isAccurate, isFalse);
    });

    test('Accepts accurately traced ㄱ (top bar then down)', () {
      // Checkpoints for ㄱ are top-left to top-right to bottom-right
      final stroke1 = [
        const Offset(84, 96),   // near (0.28, 0.30)
        const Offset(110, 96),
        const Offset(144, 96),  // (0.48, 0.30)
        const Offset(170, 96),
        const Offset(204, 96),  // corner (0.68, 0.30)
        const Offset(204, 130),
        const Offset(204, 160), // (0.68, 0.50)
        const Offset(204, 190),
        const Offset(204, 224), // (0.68, 0.70)
      ];

      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄱ',
        strokes: [stroke1],
        canvasSize: canvasSize,
      );
      expect(res.isAccurate, isTrue);
      expect(res.feedbackMessage, contains('Beautiful'));
      expect(res.accuracyScore, greaterThan(0.7));
    });
  });
}
