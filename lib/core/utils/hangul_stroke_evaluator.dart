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

class StrokeGuideStep {
  final int number;
  final Offset position; // Normalized 0.0 to 1.0
  final String directionHint; // e.g. "1 →", "2 ↓"

  const StrokeGuideStep({
    required this.number,
    required this.position,
    required this.directionHint,
  });
}

class HangulCharacterDefinition {
  final String character;
  final List<List<Offset>> templatePaths;
  final List<Offset> mandatoryCorners;
  final List<Offset> forbiddenCutZones;
  final List<StrokeGuideStep> guideSteps;

  const HangulCharacterDefinition({
    required this.character,
    required this.templatePaths,
    required this.mandatoryCorners,
    required this.forbiddenCutZones,
    required this.guideSteps,
  });
}

class HangulStrokeEvaluator {
  static const Map<String, HangulCharacterDefinition> _definitions = {
    'ㄱ': HangulCharacterDefinition(
      character: 'ㄱ',
      templatePaths: [
        [
          Offset(0.28, 0.32),
          Offset(0.50, 0.32),
          Offset(0.72, 0.32), // Top-right corner
          Offset(0.72, 0.52),
          Offset(0.72, 0.72), // Bottom-right end
        ],
      ],
      mandatoryCorners: [
        Offset(0.72, 0.32), // Must visit top-right corner!
      ],
      forbiddenCutZones: [
        Offset(0.48, 0.52), // Diagonal hypotenuse cutting corner
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.24, 0.24), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.76, 0.32), directionHint: '2 ↴'),
      ],
    ),
    'ㄴ': HangulCharacterDefinition(
      character: 'ㄴ',
      templatePaths: [
        [
          Offset(0.30, 0.28),
          Offset(0.30, 0.50),
          Offset(0.30, 0.72), // Bottom-left corner
          Offset(0.52, 0.72),
          Offset(0.72, 0.72), // Bottom-right end
        ],
      ],
      mandatoryCorners: [
        Offset(0.30, 0.72), // Must visit bottom-left corner!
      ],
      forbiddenCutZones: [
        Offset(0.50, 0.50), // Diagonal hypotenuse
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.22, 0.28), directionHint: '1 ↓'),
        StrokeGuideStep(number: 2, position: Offset(0.30, 0.80), directionHint: '2 ➔'),
      ],
    ),
    'ㄷ': HangulCharacterDefinition(
      character: 'ㄷ',
      templatePaths: [
        [
          Offset(0.30, 0.30),
          Offset(0.50, 0.30),
          Offset(0.70, 0.30),
        ],
        [
          Offset(0.30, 0.30),
          Offset(0.30, 0.50),
          Offset(0.30, 0.72),
          Offset(0.50, 0.72),
          Offset(0.70, 0.72),
        ],
      ],
      mandatoryCorners: [
        Offset(0.30, 0.72),
      ],
      forbiddenCutZones: [
        Offset(0.50, 0.52),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.30, 0.22), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.22, 0.38), directionHint: '2 ↓'),
        StrokeGuideStep(number: 3, position: Offset(0.50, 0.80), directionHint: '3 ➔'),
      ],
    ),
    'ㄹ': HangulCharacterDefinition(
      character: 'ㄹ',
      templatePaths: [
        [
          Offset(0.30, 0.28),
          Offset(0.70, 0.28),
          Offset(0.70, 0.49),
          Offset(0.30, 0.49),
          Offset(0.30, 0.72),
          Offset(0.70, 0.72),
        ],
      ],
      mandatoryCorners: [
        Offset(0.70, 0.28),
        Offset(0.30, 0.49),
        Offset(0.30, 0.72),
      ],
      forbiddenCutZones: [
        Offset(0.50, 0.38),
        Offset(0.50, 0.60),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.30, 0.20), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.70, 0.56), directionHint: '2 ⟵'),
        StrokeGuideStep(number: 3, position: Offset(0.30, 0.80), directionHint: '3 ➔'),
      ],
    ),
    'ㅏ': HangulCharacterDefinition(
      character: 'ㅏ',
      templatePaths: [
        [
          Offset(0.48, 0.20),
          Offset(0.48, 0.50),
          Offset(0.48, 0.80),
        ],
        [
          Offset(0.48, 0.50),
          Offset(0.74, 0.50),
        ],
      ],
      mandatoryCorners: [
        Offset(0.48, 0.50),
        Offset(0.74, 0.50),
      ],
      forbiddenCutZones: [
        Offset(0.64, 0.32),
        Offset(0.64, 0.68),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.48, 0.12), directionHint: '1 ↓'),
        StrokeGuideStep(number: 2, position: Offset(0.74, 0.42), directionHint: '2 ➔'),
      ],
    ),
    'ㅗ': HangulCharacterDefinition(
      character: 'ㅗ',
      templatePaths: [
        [
          Offset(0.50, 0.24),
          Offset(0.50, 0.56),
        ],
        [
          Offset(0.24, 0.56),
          Offset(0.50, 0.56),
          Offset(0.76, 0.56),
        ],
      ],
      mandatoryCorners: [
        Offset(0.50, 0.24),
        Offset(0.50, 0.56),
      ],
      forbiddenCutZones: [
        Offset(0.34, 0.38),
        Offset(0.66, 0.38),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.50, 0.16), directionHint: '1 ↓'),
        StrokeGuideStep(number: 2, position: Offset(0.24, 0.64), directionHint: '2 ➔'),
      ],
    ),
  };

  static HangulCharacterDefinition getDefinition(String char) {
    return _definitions[char] ??
        HangulCharacterDefinition(
          character: char,
          templatePaths: [
            [
              const Offset(0.35, 0.35),
              const Offset(0.65, 0.35),
              const Offset(0.50, 0.50),
              const Offset(0.35, 0.65),
              const Offset(0.65, 0.65),
            ],
          ],
          mandatoryCorners: const [Offset(0.50, 0.50)],
          forbiddenCutZones: const [],
          guideSteps: const [
            StrokeGuideStep(number: 1, position: Offset(0.35, 0.26), directionHint: '1 ➔'),
          ],
        );
  }

  static List<StrokeGuideStep> getGuideSteps(String char) {
    return getDefinition(char).guideSteps;
  }

  static List<List<Offset>> getTemplatePaths(String char) {
    return getDefinition(char).templatePaths;
  }

  /// Strict and intelligent evaluator rejecting diagonals and missed corners
  static StrokeEvaluationResult evaluate({
    required String character,
    required List<List<Offset>> strokes,
    required Size canvasSize,
  }) {
    final def = getDefinition(character);
    final allPoints = strokes.expand((s) => s).toList();

    // 1. Min points check
    if (allPoints.length < 8) {
      return const StrokeEvaluationResult(
        isAccurate: false,
        accuracyScore: 0.1,
        feedbackMessage: 'That was too short! Follow the full shape with your finger 😊',
      );
    }

    // Convert all points to normalized (0.0 to 1.0)
    final normPoints = allPoints
        .map((p) => Offset(p.dx / canvasSize.width, p.dy / canvasSize.height))
        .toList();

    // 2. Mandatory Corner Check (Rejects diagonals that cut across corners!)
    const cornerTolerance = 0.125; // ~40px threshold
    for (final corner in def.mandatoryCorners) {
      bool cornerReached = false;
      for (final pt in normPoints) {
        if ((pt - corner).distance <= cornerTolerance) {
          cornerReached = true;
          break;
        }
      }

      if (!cornerReached) {
        if (character == 'ㄱ') {
          return const StrokeEvaluationResult(
            isAccurate: false,
            accuracyScore: 0.35,
            feedbackMessage:
                'You cut across! Don\'t draw a diagonal — slide across to the top-right corner, then go down!',
          );
        } else if (character == 'ㄴ') {
          return const StrokeEvaluationResult(
            isAccurate: false,
            accuracyScore: 0.35,
            feedbackMessage:
                'You cut across! Go straight down to the bottom-left corner first, then turn right!',
          );
        } else {
          return StrokeEvaluationResult(
            isAccurate: false,
            accuracyScore: 0.35,
            feedbackMessage:
                'You missed the corner of "$character"! Follow the arrows to make a crisp turn.',
          );
        }
      }
    }

    // 3. Forbidden Cut Zone Check (Detects cutting through hollow center)
    const cutZoneTolerance = 0.085;
    for (final cutZone in def.forbiddenCutZones) {
      int cutPoints = 0;
      for (final pt in normPoints) {
        if ((pt - cutZone).distance <= cutZoneTolerance) {
          cutPoints++;
        }
      }
      if (cutPoints >= 3) {
        return StrokeEvaluationResult(
          isAccurate: false,
          accuracyScore: 0.4,
          feedbackMessage:
              'Diagonal shortcut detected! Follow the outside right angle to write "$character".',
        );
      }
    }

    // 4. Path Coverage Check
    // Sample checkpoints from template paths
    final allTemplateCheckpoints = def.templatePaths.expand((path) => path).toList();
    const coverageTolerance = 0.13;
    int coveredCheckpoints = 0;

    for (final cp in allTemplateCheckpoints) {
      bool covered = false;
      for (final pt in normPoints) {
        if ((pt - cp).distance <= coverageTolerance) {
          covered = true;
          break;
        }
      }
      if (covered) {
        coveredCheckpoints++;
      }
    }

    final coverageRatio = coveredCheckpoints / allTemplateCheckpoints.length;
    if (coverageRatio < 0.70) {
      return StrokeEvaluationResult(
        isAccurate: false,
        accuracyScore: coverageRatio,
        feedbackMessage:
            'Almost! Trace more along the guide outline to complete "$character".',
      );
    }

    // 5. Stray points penalty
    const maxStrayDistance = 0.22;
    int strayCount = 0;
    for (final pt in normPoints) {
      double minDist = double.infinity;
      for (final cp in allTemplateCheckpoints) {
        final d = (pt - cp).distance;
        if (d < minDist) minDist = d;
      }
      if (minDist > maxStrayDistance) {
        strayCount++;
      }
    }

    final strayRatio = strayCount / normPoints.length;
    if (strayRatio > 0.35) {
      return StrokeEvaluationResult(
        isAccurate: false,
        accuracyScore: math.max(0.2, coverageRatio - strayRatio),
        feedbackMessage:
            'Too many stray lines outside the shape. Follow the faint "$character" outline!',
      );
    }

    final finalScore = math.min(1.0, coverageRatio * (1.0 - (strayRatio * 0.4)));

    return StrokeEvaluationResult(
      isAccurate: true,
      accuracyScore: finalScore,
      feedbackMessage: 'Beautiful! You wrote "$character" with a crisp right angle! ✨',
    );
  }
}
