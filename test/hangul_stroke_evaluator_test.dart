import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_korean/core/utils/hangul_stroke_evaluator.dart';

void main() {
  group('HangulStrokeEvaluator Strict Shape & Corner Tests', () {
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

    test('REJECTS diagonal shortcut on ㄱ (screenshot 1 scenario)', () {
      // User draws a diagonal cutting directly from (0.28, 0.32) to (0.72, 0.72)
      final diagonalStroke = List.generate(
        20,
        (i) {
          final t = i / 19.0;
          final x = (0.28 + t * (0.72 - 0.28)) * canvasSize.width;
          final y = (0.32 + t * (0.72 - 0.32)) * canvasSize.height;
          return Offset(x, y);
        },
      );

      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄱ',
        strokes: [diagonalStroke],
        canvasSize: canvasSize,
      );

      expect(res.isAccurate, isFalse);
      expect(res.feedbackMessage, contains('cut across'));
    });

    test('REJECTS diagonal shortcut on ㄴ (screenshot 2 scenario)', () {
      // User draws a diagonal cutting directly across ㄴ
      final diagonalStroke = List.generate(
        20,
        (i) {
          final t = i / 19.0;
          final x = (0.30 + t * (0.72 - 0.30)) * canvasSize.width;
          final y = (0.28 + t * (0.72 - 0.28)) * canvasSize.height;
          return Offset(x, y);
        },
      );

      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄴ',
        strokes: [diagonalStroke],
        canvasSize: canvasSize,
      );

      expect(res.isAccurate, isFalse);
      expect(res.feedbackMessage, contains('cut across'));
    });

    test('ACCEPTS properly traced ㄱ with corner', () {
      // Top bar from (0.28, 0.32) to corner (0.72, 0.32), then down to (0.72, 0.72)
      final topBar = List.generate(
        10,
        (i) {
          final t = i / 9.0;
          return Offset(
            (0.28 + t * (0.72 - 0.28)) * canvasSize.width,
            0.32 * canvasSize.height,
          );
        },
      );

      final downStem = List.generate(
        10,
        (i) {
          final t = i / 9.0;
          return Offset(
            0.72 * canvasSize.width,
            (0.32 + t * (0.72 - 0.32)) * canvasSize.height,
          );
        },
      );

      final properG = [...topBar, ...downStem];

      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄱ',
        strokes: [properG],
        canvasSize: canvasSize,
      );

      expect(res.isAccurate, isTrue);
      expect(res.feedbackMessage, contains('Beautiful'));
      expect(res.accuracyScore, greaterThan(0.7));
    });

    test('ACCEPTS properly traced ㄴ with corner', () {
      // Down stem from (0.30, 0.28) to corner (0.30, 0.72), then right to (0.72, 0.72)
      final downStem = List.generate(
        10,
        (i) {
          final t = i / 9.0;
          return Offset(
            0.30 * canvasSize.width,
            (0.28 + t * (0.72 - 0.28)) * canvasSize.height,
          );
        },
      );

      final rightBar = List.generate(
        10,
        (i) {
          final t = i / 9.0;
          return Offset(
            (0.30 + t * (0.72 - 0.30)) * canvasSize.width,
            0.72 * canvasSize.height,
          );
        },
      );

      final properN = [...downStem, ...rightBar];

      final res = HangulStrokeEvaluator.evaluate(
        character: 'ㄴ',
        strokes: [properN],
        canvasSize: canvasSize,
      );

      expect(res.isAccurate, isTrue);
      expect(res.feedbackMessage, contains('Beautiful'));
      expect(res.accuracyScore, greaterThan(0.7));
    });
  });
}
