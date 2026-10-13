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

/// A line segment defined by start and end points
class CharacterSegment {
  final Offset start;
  final Offset end;
  final String segmentName;

  const CharacterSegment({
    required this.start,
    required this.end,
    required this.segmentName,
  });
}

class HangulCharacterDefinition {
  final String character;
  final List<List<Offset>> templatePaths;
  final List<CharacterSegment> segments;
  final List<Offset> mandatoryCorners;
  final List<Offset> forbiddenCutZones;
  final List<StrokeGuideStep> guideSteps;
  final int maxStrokesAllowed;
  final bool isOpenShape;

  const HangulCharacterDefinition({
    required this.character,
    required this.templatePaths,
    required this.segments,
    required this.mandatoryCorners,
    required this.forbiddenCutZones,
    required this.guideSteps,
    this.maxStrokesAllowed = 2,
    this.isOpenShape = true,
  });
}

class HangulStrokeEvaluator {
  static const Map<String, HangulCharacterDefinition> _definitions = {
    'ㄱ': HangulCharacterDefinition(
      character: 'ㄱ',
      maxStrokesAllowed: 2,
      isOpenShape: true,
      templatePaths: [
        [
          Offset(0.28, 0.32),
          Offset(0.50, 0.32),
          Offset(0.72, 0.32),
          Offset(0.72, 0.52),
          Offset(0.72, 0.72),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.28, 0.32),
          end: Offset(0.72, 0.32),
          segmentName: 'top horizontal bar',
        ),
        CharacterSegment(
          start: Offset(0.72, 0.32),
          end: Offset(0.72, 0.72),
          segmentName: 'downward vertical line',
        ),
      ],
      mandatoryCorners: [
        Offset(0.72, 0.32),
      ],
      forbiddenCutZones: [
        Offset(0.48, 0.52),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.24, 0.24), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.76, 0.32), directionHint: '2 ↴'),
      ],
    ),
    'ㄴ': HangulCharacterDefinition(
      character: 'ㄴ',
      maxStrokesAllowed: 2,
      isOpenShape: true,
      templatePaths: [
        [
          Offset(0.30, 0.28),
          Offset(0.30, 0.50),
          Offset(0.30, 0.72),
          Offset(0.52, 0.72),
          Offset(0.72, 0.72),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.30, 0.28),
          end: Offset(0.30, 0.72),
          segmentName: 'downward vertical line',
        ),
        CharacterSegment(
          start: Offset(0.30, 0.72),
          end: Offset(0.72, 0.72),
          segmentName: 'bottom horizontal bar',
        ),
      ],
      mandatoryCorners: [
        Offset(0.30, 0.72),
      ],
      forbiddenCutZones: [
        Offset(0.50, 0.50),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.22, 0.28), directionHint: '1 ↓'),
        StrokeGuideStep(number: 2, position: Offset(0.30, 0.80), directionHint: '2 ➔'),
      ],
    ),
    'ㄷ': HangulCharacterDefinition(
      character: 'ㄷ',
      maxStrokesAllowed: 3,
      isOpenShape: true,
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
      segments: [
        CharacterSegment(
          start: Offset(0.30, 0.30),
          end: Offset(0.70, 0.30),
          segmentName: 'top bar',
        ),
        CharacterSegment(
          start: Offset(0.30, 0.30),
          end: Offset(0.30, 0.72),
          segmentName: 'left vertical stem',
        ),
        CharacterSegment(
          start: Offset(0.30, 0.72),
          end: Offset(0.70, 0.72),
          segmentName: 'bottom bar',
        ),
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
      maxStrokesAllowed: 4,
      isOpenShape: true,
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
      segments: [
        CharacterSegment(
          start: Offset(0.30, 0.28),
          end: Offset(0.70, 0.28),
          segmentName: 'top bar',
        ),
        CharacterSegment(
          start: Offset(0.70, 0.28),
          end: Offset(0.70, 0.49),
          segmentName: 'upper right drop',
        ),
        CharacterSegment(
          start: Offset(0.70, 0.49),
          end: Offset(0.30, 0.49),
          segmentName: 'middle bar',
        ),
        CharacterSegment(
          start: Offset(0.30, 0.49),
          end: Offset(0.30, 0.72),
          segmentName: 'lower left drop',
        ),
        CharacterSegment(
          start: Offset(0.30, 0.72),
          end: Offset(0.70, 0.72),
          segmentName: 'bottom bar',
        ),
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
      maxStrokesAllowed: 2,
      isOpenShape: true,
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
      segments: [
        CharacterSegment(
          start: Offset(0.48, 0.20),
          end: Offset(0.48, 0.80),
          segmentName: 'vertical stem',
        ),
        CharacterSegment(
          start: Offset(0.48, 0.50),
          end: Offset(0.74, 0.50),
          segmentName: 'branch stroke to the right',
        ),
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
      maxStrokesAllowed: 2,
      isOpenShape: true,
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
      segments: [
        CharacterSegment(
          start: Offset(0.50, 0.24),
          end: Offset(0.50, 0.56),
          segmentName: 'vertical stem',
        ),
        CharacterSegment(
          start: Offset(0.24, 0.56),
          end: Offset(0.76, 0.56),
          segmentName: 'horizontal base',
        ),
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
          maxStrokesAllowed: 3,
          isOpenShape: true,
          templatePaths: [
            [
              const Offset(0.35, 0.35),
              const Offset(0.65, 0.35),
              const Offset(0.50, 0.50),
              const Offset(0.35, 0.65),
              const Offset(0.65, 0.65),
            ],
          ],
          segments: [
            const CharacterSegment(
              start: Offset(0.35, 0.35),
              end: Offset(0.65, 0.35),
              segmentName: 'stroke',
            ),
          ],
          mandatoryCorners: const [Offset(0.50, 0.50)],
          forbiddenCutZones: const [],
          guideSteps: const [
            StrokeGuideStep(number: 1, position: Offset(0.35, 0.26), directionHint: '1 ➔'),
          ],
        );
  }

  static List<StrokeGuideStep> getGuideSteps(String char) => getDefinition(char).guideSteps;

  static List<List<Offset>> getTemplatePaths(String char) => getDefinition(char).templatePaths;

  /// Strict handwriting verifier preventing dot-skips, loop exploits, and missing segments
  static StrokeEvaluationResult evaluate({
    required String character,
    required List<List<Offset>> strokes,
    required Size canvasSize,
  }) {
    final def = getDefinition(character);

    // Filter out accidental empty sub-strokes
    final activeStrokes = strokes.where((s) => s.isNotEmpty).toList();

    // 1. Dotted Tap Exploit Check (Screenshot 4)
    // If the learner lifts their finger repeatedly and leaves many short dots
    if (activeStrokes.length > def.maxStrokesAllowed) {
      return StrokeEvaluationResult(
        isAccurate: false,
        accuracyScore: 0.2,
        feedbackMessage:
            'Trace in smooth, continuous stroke(s)! Don\'t lift your finger to tap dots 😊',
      );
    }

    final allPoints = activeStrokes.expand((s) => s).toList();

    // Minimum total points check
    if (allPoints.length < 12) {
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

    // 2. Closed Loop Exploit Check (Screenshot 3)
    // If character is an open shape (like ㄱ, ㄴ, ㄷ), verify start and end aren't closed into a loop
    if (def.isOpenShape) {
      for (final stroke in activeStrokes) {
        if (stroke.length >= 8) {
          final first = Offset(stroke.first.dx / canvasSize.width, stroke.first.dy / canvasSize.height);
          final last = Offset(stroke.last.dx / canvasSize.width, stroke.last.dy / canvasSize.height);
          if ((first - last).distance < 0.11) {
            return StrokeEvaluationResult(
              isAccurate: false,
              accuracyScore: 0.3,
              feedbackMessage:
                  '"$character" is an open shape, not a closed loop! Don\'t connect the ends.',
            );
          }
        }
      }
    }

    // 3. Mandatory Corner Check
    const cornerTolerance = 0.11;
    for (final corner in def.mandatoryCorners) {
      bool cornerReached = false;
      for (final pt in normPoints) {
        if ((pt - corner).distance <= cornerTolerance) {
          cornerReached = true;
          break;
        }
      }

      if (!cornerReached) {
        return StrokeEvaluationResult(
          isAccurate: false,
          accuracyScore: 0.35,
          feedbackMessage:
              'You missed the corner of "$character"! Slide across and make a crisp turn.',
        );
      }
    }

    // 4. Forbidden Cut Zone Check (Diagonal Hypotenuse)
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
          accuracyScore: 0.35,
          feedbackMessage:
              'Diagonal shortcut detected! Follow the outside right angle of "$character".',
        );
      }
    }

    // 5. Segment-by-Segment Completeness Check (Screenshots 1 & 2)
    // Every single segment (e.g. horizontal bar AND vertical stem) must have >= 65% continuous coverage!
    const segmentTolerance = 0.095;
    for (final segment in def.segments) {
      const sampleSteps = 10;
      int coveredSteps = 0;

      for (int i = 0; i <= sampleSteps; i++) {
        final t = i / sampleSteps.toDouble();
        final targetPoint = Offset(
          segment.start.dx + t * (segment.end.dx - segment.start.dx),
          segment.start.dy + t * (segment.end.dy - segment.start.dy),
        );

        bool stepCovered = false;
        for (final pt in normPoints) {
          if ((pt - targetPoint).distance <= segmentTolerance) {
            stepCovered = true;
            break;
          }
        }
        if (stepCovered) {
          coveredSteps++;
        }
      }

      final segmentCoverage = coveredSteps / (sampleSteps + 1);
      if (segmentCoverage < 0.65) {
        return StrokeEvaluationResult(
          isAccurate: false,
          accuracyScore: segmentCoverage,
          feedbackMessage:
              'Incomplete! You missed the ${segment.segmentName} of "$character". Trace both sides fully!',
        );
      }
    }

    // 6. Stray points penalty
    final allCheckpoints = def.templatePaths.expand((p) => p).toList();
    const maxStrayDistance = 0.20;
    int strayCount = 0;
    for (final pt in normPoints) {
      double minDist = double.infinity;
      for (final cp in allCheckpoints) {
        final d = (pt - cp).distance;
        if (d < minDist) minDist = d;
      }
      if (minDist > maxStrayDistance) {
        strayCount++;
      }
    }

    final strayRatio = strayCount / normPoints.length;
    if (strayRatio > 0.30) {
      return StrokeEvaluationResult(
        isAccurate: false,
        accuracyScore: 0.4,
        feedbackMessage:
            'Too many stray lines outside the stencil. Stay inside the grey track of "$character"!',
      );
    }

    return StrokeEvaluationResult(
      isAccurate: true,
      accuracyScore: 0.95,
      feedbackMessage: 'Beautiful! You wrote "$character" with full strokes & clean corners! ✨',
    );
  }
}
