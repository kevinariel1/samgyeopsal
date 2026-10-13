import 'dart:math' as math;
import 'package:flutter/material.dart';

class StrokeEvaluationResult {
  final bool isAccurate;
  final double accuracyScore; // 0.0 to 1.0
  final String feedbackMessage;

  const StrokeEvaluationResult({
    required this.isAccurate,
    required this.accuracyScore,
    required this.feedbackMessage,
  });
}

/// Stroke guide definition containing numbered step checkpoints for visual guidance and verification
class StrokeGuideStep {
  final int number;
  final Offset position; // Normalized 0.0 to 1.0
  final String directionHint; // e.g. "→", "↓", "↳"

  const StrokeGuideStep({
    required this.number,
    required this.position,
    required this.directionHint,
  });
}

class HangulStrokeEvaluator {
  /// Returns normalized checkpoints representing the skeleton of the letter
  static List<Offset> getCheckpoints(String character) {
    switch (character) {
      case 'ㄱ':
        return const [
          Offset(0.28, 0.30),
          Offset(0.48, 0.30),
          Offset(0.68, 0.30), // Corner
          Offset(0.68, 0.50),
          Offset(0.68, 0.70),
        ];

      case 'ㄴ':
        return const [
          Offset(0.32, 0.30),
          Offset(0.32, 0.50),
          Offset(0.32, 0.70), // Corner
          Offset(0.52, 0.70),
          Offset(0.72, 0.70),
        ];

      case 'ㄷ':
        return const [
          Offset(0.30, 0.30),
          Offset(0.50, 0.30),
          Offset(0.70, 0.30), // Top bar
          Offset(0.30, 0.50), // Vertical stem
          Offset(0.30, 0.70), // Bottom left
          Offset(0.50, 0.70),
          Offset(0.70, 0.70), // Bottom bar
        ];

      case 'ㄹ':
        return const [
          Offset(0.30, 0.28),
          Offset(0.50, 0.28),
          Offset(0.70, 0.28), // 1. Top bar
          Offset(0.70, 0.40), // 2. Right drop
          Offset(0.50, 0.49),
          Offset(0.30, 0.49), // 3. Middle bar
          Offset(0.30, 0.60), // 4. Left drop
          Offset(0.50, 0.71),
          Offset(0.70, 0.71), // 5. Bottom bar
        ];

      case 'ㅏ':
        return const [
          Offset(0.46, 0.22),
          Offset(0.46, 0.36),
          Offset(0.46, 0.50),
          Offset(0.46, 0.64),
          Offset(0.46, 0.78), // Long vertical
          Offset(0.58, 0.50),
          Offset(0.70, 0.50), // Short branch right
        ];

      case 'ㅗ':
        return const [
          Offset(0.50, 0.26),
          Offset(0.50, 0.38),
          Offset(0.50, 0.50), // Vertical stem
          Offset(0.26, 0.50),
          Offset(0.38, 0.50),
          Offset(0.62, 0.50),
          Offset(0.74, 0.50), // Horizontal bar
        ];

      case '가':
        return const [
          // ㄱ part
          Offset(0.22, 0.30),
          Offset(0.38, 0.30),
          Offset(0.38, 0.50),
          Offset(0.38, 0.70),
          // ㅏ part
          Offset(0.64, 0.24),
          Offset(0.64, 0.50),
          Offset(0.64, 0.76),
          Offset(0.76, 0.50),
        ];

      case '나':
        return const [
          // ㄴ part
          Offset(0.24, 0.32),
          Offset(0.24, 0.68),
          Offset(0.44, 0.68),
          // ㅏ part
          Offset(0.66, 0.24),
          Offset(0.66, 0.50),
          Offset(0.66, 0.76),
          Offset(0.78, 0.50),
        ];

      default:
        // Generic fallback skeleton
        return const [
          Offset(0.35, 0.35),
          Offset(0.65, 0.35),
          Offset(0.50, 0.50),
          Offset(0.35, 0.65),
          Offset(0.65, 0.65),
        ];
    }
  }

  /// Visual stroke step arrows
  static List<StrokeGuideStep> getGuideSteps(String character) {
    switch (character) {
      case 'ㄱ':
        return const [
          StrokeGuideStep(number: 1, position: Offset(0.28, 0.30), directionHint: '1 ➔'),
          StrokeGuideStep(number: 2, position: Offset(0.68, 0.30), directionHint: '2 ↴'),
        ];
      case 'ㄴ':
        return const [
          StrokeGuideStep(number: 1, position: Offset(0.32, 0.30), directionHint: '1 ↓'),
          StrokeGuideStep(number: 2, position: Offset(0.32, 0.70), directionHint: '2 ➔'),
        ];
      case 'ㄷ':
        return const [
          StrokeGuideStep(number: 1, position: Offset(0.30, 0.30), directionHint: '1 ➔'),
          StrokeGuideStep(number: 2, position: Offset(0.30, 0.34), directionHint: '2 ↓'),
          StrokeGuideStep(number: 3, position: Offset(0.30, 0.70), directionHint: '3 ➔'),
        ];
      case 'ㄹ':
        return const [
          StrokeGuideStep(number: 1, position: Offset(0.30, 0.28), directionHint: '1 ➔'),
          StrokeGuideStep(number: 2, position: Offset(0.70, 0.49), directionHint: '2 ⟵'),
          StrokeGuideStep(number: 3, position: Offset(0.30, 0.71), directionHint: '3 ➔'),
        ];
      case 'ㅏ':
        return const [
          StrokeGuideStep(number: 1, position: Offset(0.46, 0.22), directionHint: '1 ↓'),
          StrokeGuideStep(number: 2, position: Offset(0.46, 0.50), directionHint: '2 ➔'),
        ];
      case 'ㅗ':
        return const [
          StrokeGuideStep(number: 1, position: Offset(0.50, 0.26), directionHint: '1 ↓'),
          StrokeGuideStep(number: 2, position: Offset(0.26, 0.50), directionHint: '2 ➔'),
        ];
      default:
        return const [
          StrokeGuideStep(number: 1, position: Offset(0.35, 0.35), directionHint: '1 ➔'),
        ];
    }
  }

  /// Evaluates user's drawn strokes against the character skeleton
  static StrokeEvaluationResult evaluate({
    required String character,
    required List<List<Offset>> strokes,
    required Size canvasSize,
  }) {
    // 1. Check if user actually drew anything substantial
    final allPoints = strokes.expand((s) => s).toList();
    if (allPoints.length < 8) {
      return const StrokeEvaluationResult(
        isAccurate: false,
        accuracyScore: 0.1,
        feedbackMessage: 'That was too short! Try tracing the full shape with your finger 😊',
      );
    }

    final checkpoints = getCheckpoints(character);
    // Tolerance radius scaled to canvas width (~15% of width, approx 45-50 dp)
    final toleranceRadius = canvasSize.width * 0.16;
    final maxDistanceAllowed = toleranceRadius * 2.2;

    int coveredCheckpoints = 0;
    for (final cpNorm in checkpoints) {
      final cpScreen = Offset(cpNorm.dx * canvasSize.width, cpNorm.dy * canvasSize.height);
      bool isCovered = false;
      for (final pt in allPoints) {
        final dist = (pt - cpScreen).distance;
        if (dist <= toleranceRadius) {
          isCovered = true;
          break;
        }
      }
      if (isCovered) {
        coveredCheckpoints++;
      }
    }

    final coverageRatio = coveredCheckpoints / checkpoints.length;

    // 2. Check for stray/off-target points (detecting if user drew something completely different)
    int strayCount = 0;
    for (final pt in allPoints) {
      double minDistanceToAnyCheckpoint = double.infinity;
      for (final cpNorm in checkpoints) {
        final cpScreen = Offset(cpNorm.dx * canvasSize.width, cpNorm.dy * canvasSize.height);
        final dist = (pt - cpScreen).distance;
        if (dist < minDistanceToAnyCheckpoint) {
          minDistanceToAnyCheckpoint = dist;
        }
      }
      if (minDistanceToAnyCheckpoint > maxDistanceAllowed) {
        strayCount++;
      }
    }

    final strayRatio = strayCount / allPoints.length;

    // 3. Formulate verdict
    // If the learner covered less than 65% of the target points
    if (coverageRatio < 0.65) {
      return StrokeEvaluationResult(
        isAccurate: false,
        accuracyScore: coverageRatio,
        feedbackMessage: 'Missed some parts of "$character"! Follow the guide arrows from top to bottom.',
      );
    }

    // If more than 38% of the drawn points are way off the character
    if (strayRatio > 0.38) {
      return StrokeEvaluationResult(
        isAccurate: false,
        accuracyScore: math.max(0.2, coverageRatio - strayRatio),
        feedbackMessage: 'Oops! That looks like a different shape. Stay close to the faint "$character" outline!',
      );
    }

    final finalScore = math.min(1.0, coverageRatio * (1.0 - (strayRatio * 0.5)));

    return StrokeEvaluationResult(
      isAccurate: true,
      accuracyScore: finalScore,
      feedbackMessage: 'Beautiful! You wrote "$character" perfectly! ✨',
    );
  }
}
