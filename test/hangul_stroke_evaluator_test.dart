import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_korean/core/utils/hangul_stroke_evaluator.dart';

void main() {
  group('HangulStrokeEvaluator Strict Shape & Exploit Prevention', () {
    const canvasSize = Size(300, 320);

    test('Exploit 1 (Screenshot 1): REJECTS missing vertical line with only a dot at the end', () {
      // Horizontal bar drawn, but vertical stem is empty except for a dot at bottom
      final topBar = List.generate(
        12,
        (i) => Offset((0.28 + (i / 11.0) * (0.72 - 0.28)) * canvasSize.width, 0.32 * canvasSize.height),
      );
      final bottomDot = [
        Offset(0.72 * canvasSize.width, 0.70 * canvasSize.height),
        Offset(0.72 * canvasSize.width, 0.71 * canvasSize.height),
      ];

      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄱ',
        strokes: [topBar, bottomDot],
        canvasSize: canvasSize,
      );

      expect(res.isAccurate, isFalse);
      expect(res.feedbackMessage, contains('downward vertical line'));
    });

    test('Exploit 2 (Screenshot 2): REJECTS missing horizontal bar with only vertical line drawn', () {
      final topDot = [
        Offset(0.28 * canvasSize.width, 0.32 * canvasSize.height),
        Offset(0.29 * canvasSize.width, 0.32 * canvasSize.height),
      ];
      final verticalStem = List.generate(
        12,
        (i) => Offset(0.72 * canvasSize.width, (0.32 + (i / 11.0) * (0.72 - 0.32)) * canvasSize.height),
      );

      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄱ',
        strokes: [topDot, verticalStem],
        canvasSize: canvasSize,
      );

      expect(res.isAccurate, isFalse);
      expect(res.feedbackMessage, contains('top horizontal bar'));
    });

    test('Exploit 3 (Screenshot 3): REJECTS closed loop / triangle returning to start', () {
      // Stroke starts at (0.28, 0.32), goes to corner, down, and curves back to start
      final loopWaypoints = [
        const Offset(0.28, 0.32),
        const Offset(0.50, 0.32),
        const Offset(0.72, 0.32),
        const Offset(0.72, 0.55),
        const Offset(0.60, 0.65),
        const Offset(0.40, 0.55),
        const Offset(0.30, 0.40),
        const Offset(0.28, 0.32),
      ];
      final loop = <Offset>[];
      for (int i = 0; i < loopWaypoints.length - 1; i++) {
        final p1 = loopWaypoints[i];
        final p2 = loopWaypoints[i + 1];
        loop.add(Offset(p1.dx * canvasSize.width, p1.dy * canvasSize.height));
        loop.add(Offset(((p1.dx + p2.dx) / 2) * canvasSize.width, ((p1.dy + p2.dy) / 2) * canvasSize.height));
      }
      loop.add(Offset(loopWaypoints.last.dx * canvasSize.width, loopWaypoints.last.dy * canvasSize.height));

      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄱ',
        strokes: [loop],
        canvasSize: canvasSize,
      );

      expect(res.isAccurate, isFalse);
      expect(res.feedbackMessage, contains('closed loop'));
    });

    test('Exploit 4 (Screenshot 4): REJECTS dotted tapping (too many disconnected strokes)', () {
      // 8 separate dot taps
      final dots = List.generate(
        8,
        (i) => [Offset((0.28 + i * 0.05) * canvasSize.width, 0.32 * canvasSize.height)],
      );

      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄱ',
        strokes: dots,
        canvasSize: canvasSize,
      );

      expect(res.isAccurate, isFalse);
      expect(res.feedbackMessage, contains('continuous stroke'));
    });

    test('Legitimate Drawing: ACCEPTS fully drawn ㄱ with corner in 1 stroke', () {
      final stroke = <Offset>[];
      // Horizontal part
      for (int i = 0; i <= 10; i++) {
        stroke.add(Offset((0.28 + (i / 10.0) * (0.72 - 0.28)) * canvasSize.width, 0.32 * canvasSize.height));
      }
      // Vertical part
      for (int i = 1; i <= 10; i++) {
        stroke.add(Offset(0.72 * canvasSize.width, (0.32 + (i / 10.0) * (0.72 - 0.32)) * canvasSize.height));
      }

      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄱ',
        strokes: [stroke],
        canvasSize: canvasSize,
      );

      expect(res.isAccurate, isTrue);
      expect(res.feedbackMessage, contains('Beautiful'));
    });
  });
}
