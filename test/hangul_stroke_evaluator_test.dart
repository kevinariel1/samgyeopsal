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

    test('Exploit 5 (New Screenshot): REJECTS zigzag coloring / back-and-forth scribbling', () {
      // Simulate continuous dense zigzag scrub across the horizontal bar
      final zigzagStroke = <Offset>[];
      for (int i = 0; i < 20; i++) {
        final x = (0.28 + (i / 19.0) * (0.72 - 0.28)) * canvasSize.width;
        // Oscillating up and down like comb bristles
        final y = (0.32 + (i % 2 == 0 ? 0.08 : -0.08)) * canvasSize.height;
        zigzagStroke.add(Offset(x, y));
        // Backtrack
        zigzagStroke.add(Offset(x - 5, y));
      }
      // Then down to corner
      for (int i = 0; i < 10; i++) {
        final y = (0.32 + (i / 9.0) * (0.72 - 0.32)) * canvasSize.height;
        zigzagStroke.add(Offset(0.72 * canvasSize.width, y));
      }

      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄱ',
        strokes: [zigzagStroke],
        canvasSize: canvasSize,
      );

      expect(res.isAccurate, isFalse);
      expect(
        res.feedbackMessage.contains('color') || res.feedbackMessage.contains('Zigzag'),
        isTrue,
      );
    });

    test('Exploit 6 (Screenshot Bottom Blob): REJECTS scribbling/scrubbing a blob in place', () {
      final strokeWithBlob = <Offset>[];
      // Normal top bar
      for (int i = 0; i <= 10; i++) {
        strokeWithBlob.add(Offset((0.28 + (i / 10.0) * (0.72 - 0.28)) * canvasSize.width, 0.32 * canvasSize.height));
      }
      // Normal vertical stem
      for (int i = 1; i <= 8; i++) {
        strokeWithBlob.add(Offset(0.72 * canvasSize.width, (0.32 + (i / 8.0) * (0.72 - 0.32)) * canvasSize.height));
      }
      // Scrubbing circles/blobs in place at bottom endpoint (0.72, 0.72)
      for (int i = 0; i < 16; i++) {
        final bx = (0.72 + 0.015 * (i % 2 == 0 ? 1 : -1)) * canvasSize.width;
        final by = (0.72 + 0.015 * (i % 4 < 2 ? 1 : -1)) * canvasSize.height;
        strokeWithBlob.add(Offset(bx, by));
      }

      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄱ',
        strokes: [strokeWithBlob],
        canvasSize: canvasSize,
      );

      expect(res.isAccurate, isFalse);
      expect(
        res.feedbackMessage.contains('scrub') ||
            res.feedbackMessage.contains('color') ||
            res.feedbackMessage.contains('Zigzag'),
        isTrue,
      );
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

    test('Legitimate Drawing: ACCEPTS fully drawn ㄴ with corner in 1 stroke', () {
      final stroke = <Offset>[];
      // Vertical stem
      for (int i = 0; i <= 10; i++) {
        stroke.add(Offset(0.30 * canvasSize.width, (0.28 + (i / 10.0) * (0.72 - 0.28)) * canvasSize.height));
      }
      // Bottom horizontal bar
      for (int i = 1; i <= 10; i++) {
        stroke.add(Offset((0.30 + (i / 10.0) * (0.72 - 0.30)) * canvasSize.width, 0.72 * canvasSize.height));
      }

      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄴ',
        strokes: [stroke],
        canvasSize: canvasSize,
      );

      expect(res.isAccurate, isTrue);
      expect(res.feedbackMessage, contains('Beautiful'));
    });

    group('Freehand Mode (Blank Quiz Canvas - Scale & Translation Invariant)', () {
      test('ACCEPTS legitimate ㄱ drawn shifted and scaled down in freehandMode', () {
        // User draws ㄱ in top-left region (0.10 to 0.35), smaller than template
        final stroke = <Offset>[];
        // Horizontal bar from (0.10, 0.15) to (0.35, 0.15)
        for (int i = 0; i <= 10; i++) {
          stroke.add(Offset((0.10 + (i / 10.0) * 0.25) * canvasSize.width, 0.15 * canvasSize.height));
        }
        // Vertical stem from (0.35, 0.15) to (0.35, 0.40)
        for (int i = 1; i <= 10; i++) {
          stroke.add(Offset(0.35 * canvasSize.width, (0.15 + (i / 10.0) * 0.25) * canvasSize.height));
        }

        // In strict mode (with stencil guides), this would fail because it's in the top-left
        final strictRes = HangulStrokeEvaluator.evaluate(
          character: 'ㄱ',
          strokes: [stroke],
          canvasSize: canvasSize,
          freehandMode: false,
        );
        expect(strictRes.isAccurate, isFalse, reason: 'Strict mode requires following stencil');

        // In freehand mode (quiz without guides), this must PASS!
        final freehandRes = HangulStrokeEvaluator.evaluate(
          character: 'ㄱ',
          strokes: [stroke],
          canvasSize: canvasSize,
          freehandMode: true,
        );
        expect(freehandRes.isAccurate, isTrue, reason: 'Freehand mode should normalize and accept correct shape');
        expect(freehandRes.feedbackMessage, contains('Beautiful'));
      });

      test('ACCEPTS legitimate 가 drawn centered in freehandMode', () {
        // Consonant ㄱ: (0.25, 0.30) -> (0.45, 0.30) -> (0.45, 0.65)
        final stroke1 = <Offset>[];
        for (int i = 0; i <= 8; i++) {
          stroke1.add(Offset((0.25 + (i / 8.0) * 0.20) * canvasSize.width, 0.30 * canvasSize.height));
        }
        for (int i = 1; i <= 8; i++) {
          stroke1.add(Offset(0.45 * canvasSize.width, (0.30 + (i / 8.0) * 0.35) * canvasSize.height));
        }

        // Vowel vertical stem: (0.60, 0.25) -> (0.60, 0.75)
        final stroke2 = <Offset>[];
        for (int i = 0; i <= 10; i++) {
          stroke2.add(Offset(0.60 * canvasSize.width, (0.25 + (i / 10.0) * 0.50) * canvasSize.height));
        }

        // Vowel branch: (0.60, 0.50) -> (0.75, 0.50)
        final stroke3 = <Offset>[];
        for (int i = 0; i <= 6; i++) {
          stroke3.add(Offset((0.60 + (i / 6.0) * 0.15) * canvasSize.width, 0.50 * canvasSize.height));
        }

        final res = HangulStrokeEvaluator.evaluate(
          character: '가',
          strokes: [stroke1, stroke2, stroke3],
          canvasSize: canvasSize,
          freehandMode: true,
        );
        expect(res.isAccurate, isTrue);
      });

      test('REJECTS wrong character ㄴ when ㄱ is expected even in freehandMode', () {
        // User draws ㄴ instead of ㄱ
        final stroke = <Offset>[];
        for (int i = 0; i <= 10; i++) {
          stroke.add(Offset(0.20 * canvasSize.width, (0.20 + (i / 10.0) * 0.30) * canvasSize.height));
        }
        for (int i = 1; i <= 10; i++) {
          stroke.add(Offset((0.20 + (i / 10.0) * 0.30) * canvasSize.width, 0.50 * canvasSize.height));
        }

        final res = HangulStrokeEvaluator.evaluate(
          character: 'ㄱ',
          strokes: [stroke],
          canvasSize: canvasSize,
          freehandMode: true,
        );
        expect(res.isAccurate, isFalse);
      });

      test('REJECTS diagonal shortcut in freehandMode', () {
        // Stroke directly cutting hypotenuse across corner
        final stroke = <Offset>[];
        for (int i = 0; i <= 15; i++) {
          stroke.add(Offset(
            (0.20 + (i / 15.0) * 0.35) * canvasSize.width,
            (0.20 + (i / 15.0) * 0.35) * canvasSize.height,
          ));
        }

        final res = HangulStrokeEvaluator.evaluate(
          character: 'ㄱ',
          strokes: [stroke],
          canvasSize: canvasSize,
          freehandMode: true,
        );
        expect(res.isAccurate, isFalse);
      });
    });
  });
}
