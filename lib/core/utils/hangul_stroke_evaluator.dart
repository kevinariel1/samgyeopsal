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
  final Offset expectedStart;
  final Offset expectedEnd;
  final int maxStrokesAllowed;
  final bool isOpenShape;

  const HangulCharacterDefinition({
    required this.character,
    required this.templatePaths,
    required this.segments,
    required this.mandatoryCorners,
    required this.forbiddenCutZones,
    required this.guideSteps,
    required this.expectedStart,
    required this.expectedEnd,
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
      expectedStart: Offset(0.28, 0.32),
      expectedEnd: Offset(0.72, 0.72),
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
      expectedStart: Offset(0.30, 0.28),
      expectedEnd: Offset(0.72, 0.72),
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
      expectedStart: Offset(0.30, 0.30),
      expectedEnd: Offset(0.70, 0.72),
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
      expectedStart: Offset(0.30, 0.28),
      expectedEnd: Offset(0.70, 0.72),
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
      expectedStart: Offset(0.48, 0.20),
      expectedEnd: Offset(0.74, 0.50),
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
      expectedStart: Offset(0.50, 0.24),
      expectedEnd: Offset(0.76, 0.56),
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
    'ㅓ': HangulCharacterDefinition(
      character: 'ㅓ',
      maxStrokesAllowed: 2,
      isOpenShape: true,
      expectedStart: Offset(0.26, 0.50),
      expectedEnd: Offset(0.56, 0.80),
      templatePaths: [
        [
          Offset(0.26, 0.50),
          Offset(0.56, 0.50),
        ],
        [
          Offset(0.56, 0.20),
          Offset(0.56, 0.50),
          Offset(0.56, 0.80),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.26, 0.50),
          end: Offset(0.56, 0.50),
          segmentName: 'left branch stroke',
        ),
        CharacterSegment(
          start: Offset(0.56, 0.20),
          end: Offset(0.56, 0.80),
          segmentName: 'vertical stem',
        ),
      ],
      mandatoryCorners: [
        Offset(0.56, 0.50),
      ],
      forbiddenCutZones: [
        Offset(0.40, 0.32),
        Offset(0.40, 0.68),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.26, 0.40), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.56, 0.12), directionHint: '2 ↓'),
      ],
    ),
    'ㅜ': HangulCharacterDefinition(
      character: 'ㅜ',
      maxStrokesAllowed: 2,
      isOpenShape: true,
      expectedStart: Offset(0.24, 0.38),
      expectedEnd: Offset(0.50, 0.74),
      templatePaths: [
        [
          Offset(0.24, 0.38),
          Offset(0.50, 0.38),
          Offset(0.76, 0.38),
        ],
        [
          Offset(0.50, 0.38),
          Offset(0.50, 0.74),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.24, 0.38),
          end: Offset(0.76, 0.38),
          segmentName: 'horizontal ground bar',
        ),
        CharacterSegment(
          start: Offset(0.50, 0.38),
          end: Offset(0.50, 0.74),
          segmentName: 'downward vertical line',
        ),
      ],
      mandatoryCorners: [
        Offset(0.50, 0.38),
      ],
      forbiddenCutZones: [
        Offset(0.36, 0.56),
        Offset(0.64, 0.56),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.24, 0.28), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.50, 0.82), directionHint: '2 ↓'),
      ],
    ),
    '가': HangulCharacterDefinition(
      character: '가',
      maxStrokesAllowed: 4,
      isOpenShape: true,
      expectedStart: Offset(0.18, 0.28),
      expectedEnd: Offset(0.86, 0.50),
      templatePaths: [
        [
          Offset(0.18, 0.28),
          Offset(0.42, 0.28),
          Offset(0.42, 0.72),
        ],
        [
          Offset(0.64, 0.18),
          Offset(0.64, 0.82),
        ],
        [
          Offset(0.64, 0.50),
          Offset(0.86, 0.50),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.18, 0.28),
          end: Offset(0.42, 0.28),
          segmentName: 'consonant top bar',
        ),
        CharacterSegment(
          start: Offset(0.42, 0.28),
          end: Offset(0.42, 0.72),
          segmentName: 'consonant drop',
        ),
        CharacterSegment(
          start: Offset(0.64, 0.18),
          end: Offset(0.64, 0.82),
          segmentName: 'vowel stem',
        ),
        CharacterSegment(
          start: Offset(0.64, 0.50),
          end: Offset(0.86, 0.50),
          segmentName: 'vowel branch',
        ),
      ],
      mandatoryCorners: [
        Offset(0.42, 0.28),
        Offset(0.64, 0.50),
      ],
      forbiddenCutZones: [
        Offset(0.28, 0.50),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.18, 0.20), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.42, 0.80), directionHint: '2 ↓'),
        StrokeGuideStep(number: 3, position: Offset(0.64, 0.10), directionHint: '3 ↓'),
        StrokeGuideStep(number: 4, position: Offset(0.86, 0.42), directionHint: '4 ➔'),
      ],
    ),
    '나': HangulCharacterDefinition(
      character: '나',
      maxStrokesAllowed: 4,
      isOpenShape: true,
      expectedStart: Offset(0.20, 0.28),
      expectedEnd: Offset(0.86, 0.50),
      templatePaths: [
        [
          Offset(0.20, 0.28),
          Offset(0.20, 0.72),
          Offset(0.44, 0.72),
        ],
        [
          Offset(0.64, 0.18),
          Offset(0.64, 0.82),
        ],
        [
          Offset(0.64, 0.50),
          Offset(0.86, 0.50),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.20, 0.28),
          end: Offset(0.20, 0.72),
          segmentName: 'consonant drop',
        ),
        CharacterSegment(
          start: Offset(0.20, 0.72),
          end: Offset(0.44, 0.72),
          segmentName: 'consonant bottom bar',
        ),
        CharacterSegment(
          start: Offset(0.64, 0.18),
          end: Offset(0.64, 0.82),
          segmentName: 'vowel stem',
        ),
        CharacterSegment(
          start: Offset(0.64, 0.50),
          end: Offset(0.86, 0.50),
          segmentName: 'vowel branch',
        ),
      ],
      mandatoryCorners: [
        Offset(0.20, 0.72),
        Offset(0.64, 0.50),
      ],
      forbiddenCutZones: [
        Offset(0.32, 0.48),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.12, 0.28), directionHint: '1 ↓'),
        StrokeGuideStep(number: 2, position: Offset(0.44, 0.80), directionHint: '2 ➔'),
        StrokeGuideStep(number: 3, position: Offset(0.64, 0.10), directionHint: '3 ↓'),
        StrokeGuideStep(number: 4, position: Offset(0.86, 0.42), directionHint: '4 ➔'),
      ],
    ),
    '다': HangulCharacterDefinition(
      character: '다',
      maxStrokesAllowed: 5,
      isOpenShape: true,
      expectedStart: Offset(0.18, 0.28),
      expectedEnd: Offset(0.86, 0.50),
      templatePaths: [
        [
          Offset(0.18, 0.28),
          Offset(0.44, 0.28),
        ],
        [
          Offset(0.18, 0.28),
          Offset(0.18, 0.72),
          Offset(0.44, 0.72),
        ],
        [
          Offset(0.64, 0.18),
          Offset(0.64, 0.82),
        ],
        [
          Offset(0.64, 0.50),
          Offset(0.86, 0.50),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.18, 0.28),
          end: Offset(0.44, 0.28),
          segmentName: 'consonant top bar',
        ),
        CharacterSegment(
          start: Offset(0.18, 0.28),
          end: Offset(0.18, 0.72),
          segmentName: 'consonant left stem',
        ),
        CharacterSegment(
          start: Offset(0.18, 0.72),
          end: Offset(0.44, 0.72),
          segmentName: 'consonant bottom bar',
        ),
        CharacterSegment(
          start: Offset(0.64, 0.18),
          end: Offset(0.64, 0.82),
          segmentName: 'vowel stem',
        ),
        CharacterSegment(
          start: Offset(0.64, 0.50),
          end: Offset(0.86, 0.50),
          segmentName: 'vowel branch',
        ),
      ],
      mandatoryCorners: [
        Offset(0.18, 0.72),
        Offset(0.64, 0.50),
      ],
      forbiddenCutZones: [
        Offset(0.32, 0.48),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.18, 0.20), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.10, 0.38), directionHint: '2 ↓'),
        StrokeGuideStep(number: 3, position: Offset(0.44, 0.80), directionHint: '3 ➔'),
        StrokeGuideStep(number: 4, position: Offset(0.64, 0.10), directionHint: '4 ↓'),
        StrokeGuideStep(number: 5, position: Offset(0.86, 0.42), directionHint: '5 ➔'),
      ],
    ),
    '라': HangulCharacterDefinition(
      character: '라',
      maxStrokesAllowed: 6,
      isOpenShape: true,
      expectedStart: Offset(0.18, 0.26),
      expectedEnd: Offset(0.86, 0.50),
      templatePaths: [
        [
          Offset(0.18, 0.26),
          Offset(0.44, 0.26),
          Offset(0.44, 0.49),
          Offset(0.18, 0.49),
          Offset(0.18, 0.72),
          Offset(0.44, 0.72),
        ],
        [
          Offset(0.64, 0.18),
          Offset(0.64, 0.82),
        ],
        [
          Offset(0.64, 0.50),
          Offset(0.86, 0.50),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.18, 0.26),
          end: Offset(0.44, 0.26),
          segmentName: 'consonant top bar',
        ),
        CharacterSegment(
          start: Offset(0.44, 0.26),
          end: Offset(0.44, 0.49),
          segmentName: 'upper right drop',
        ),
        CharacterSegment(
          start: Offset(0.44, 0.49),
          end: Offset(0.18, 0.49),
          segmentName: 'middle bar',
        ),
        CharacterSegment(
          start: Offset(0.18, 0.49),
          end: Offset(0.18, 0.72),
          segmentName: 'lower left drop',
        ),
        CharacterSegment(
          start: Offset(0.18, 0.72),
          end: Offset(0.44, 0.72),
          segmentName: 'bottom bar',
        ),
        CharacterSegment(
          start: Offset(0.64, 0.18),
          end: Offset(0.64, 0.82),
          segmentName: 'vowel stem',
        ),
        CharacterSegment(
          start: Offset(0.64, 0.50),
          end: Offset(0.86, 0.50),
          segmentName: 'vowel branch',
        ),
      ],
      mandatoryCorners: [
        Offset(0.44, 0.26),
        Offset(0.18, 0.49),
        Offset(0.18, 0.72),
        Offset(0.64, 0.50),
      ],
      forbiddenCutZones: [
        Offset(0.30, 0.38),
        Offset(0.30, 0.60),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.18, 0.18), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.44, 0.56), directionHint: '2 ⟵'),
        StrokeGuideStep(number: 3, position: Offset(0.18, 0.80), directionHint: '3 ➔'),
        StrokeGuideStep(number: 4, position: Offset(0.64, 0.10), directionHint: '4 ↓'),
        StrokeGuideStep(number: 5, position: Offset(0.86, 0.42), directionHint: '5 ➔'),
      ],
    ),
    'ㅡ': HangulCharacterDefinition(
      character: 'ㅡ',
      maxStrokesAllowed: 1,
      isOpenShape: true,
      expectedStart: Offset(0.24, 0.50),
      expectedEnd: Offset(0.76, 0.50),
      templatePaths: [
        [
          Offset(0.24, 0.50),
          Offset(0.50, 0.50),
          Offset(0.76, 0.50),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.24, 0.50),
          end: Offset(0.76, 0.50),
          segmentName: 'horizontal earth line',
        ),
      ],
      mandatoryCorners: [],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.24, 0.40), directionHint: '1 ➔'),
      ],
    ),
    'ㅣ': HangulCharacterDefinition(
      character: 'ㅣ',
      maxStrokesAllowed: 1,
      isOpenShape: true,
      expectedStart: Offset(0.50, 0.20),
      expectedEnd: Offset(0.50, 0.80),
      templatePaths: [
        [
          Offset(0.50, 0.20),
          Offset(0.50, 0.50),
          Offset(0.50, 0.80),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.50, 0.20),
          end: Offset(0.50, 0.80),
          segmentName: 'vertical standing line',
        ),
      ],
      mandatoryCorners: [],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.50, 0.12), directionHint: '1 ↓'),
      ],
    ),
    'ㅁ': HangulCharacterDefinition(
      character: 'ㅁ',
      maxStrokesAllowed: 4,
      isOpenShape: false,
      expectedStart: Offset(0.30, 0.28),
      expectedEnd: Offset(0.70, 0.72),
      templatePaths: [
        [
          Offset(0.30, 0.28),
          Offset(0.30, 0.72),
        ],
        [
          Offset(0.30, 0.28),
          Offset(0.70, 0.28),
          Offset(0.70, 0.72),
        ],
        [
          Offset(0.30, 0.72),
          Offset(0.70, 0.72),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.30, 0.28),
          end: Offset(0.30, 0.72),
          segmentName: 'left vertical wall',
        ),
        CharacterSegment(
          start: Offset(0.30, 0.28),
          end: Offset(0.70, 0.28),
          segmentName: 'top horizontal roof',
        ),
        CharacterSegment(
          start: Offset(0.70, 0.28),
          end: Offset(0.70, 0.72),
          segmentName: 'right vertical wall',
        ),
        CharacterSegment(
          start: Offset(0.30, 0.72),
          end: Offset(0.70, 0.72),
          segmentName: 'bottom closing bar',
        ),
      ],
      mandatoryCorners: [
        Offset(0.70, 0.28),
        Offset(0.30, 0.72),
      ],
      forbiddenCutZones: [
        Offset(0.50, 0.50),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.20, 0.28), directionHint: '1 ↓'),
        StrokeGuideStep(number: 2, position: Offset(0.50, 0.20), directionHint: '2 ➔↴'),
        StrokeGuideStep(number: 3, position: Offset(0.50, 0.80), directionHint: '3 ➔'),
      ],
    ),
    'ㅂ': HangulCharacterDefinition(
      character: 'ㅂ',
      maxStrokesAllowed: 4,
      isOpenShape: false,
      expectedStart: Offset(0.30, 0.24),
      expectedEnd: Offset(0.70, 0.74),
      templatePaths: [
        [
          Offset(0.30, 0.24),
          Offset(0.30, 0.74),
        ],
        [
          Offset(0.70, 0.24),
          Offset(0.70, 0.74),
        ],
        [
          Offset(0.30, 0.50),
          Offset(0.70, 0.50),
        ],
        [
          Offset(0.30, 0.74),
          Offset(0.70, 0.74),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.30, 0.24),
          end: Offset(0.30, 0.74),
          segmentName: 'left bucket wall',
        ),
        CharacterSegment(
          start: Offset(0.70, 0.24),
          end: Offset(0.70, 0.74),
          segmentName: 'right bucket wall',
        ),
        CharacterSegment(
          start: Offset(0.30, 0.50),
          end: Offset(0.70, 0.50),
          segmentName: 'middle water line',
        ),
        CharacterSegment(
          start: Offset(0.30, 0.74),
          end: Offset(0.70, 0.74),
          segmentName: 'bottom base',
        ),
      ],
      mandatoryCorners: [
        Offset(0.30, 0.74),
        Offset(0.70, 0.74),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.20, 0.24), directionHint: '1 ↓'),
        StrokeGuideStep(number: 2, position: Offset(0.78, 0.24), directionHint: '2 ↓'),
        StrokeGuideStep(number: 3, position: Offset(0.50, 0.42), directionHint: '3 ➔'),
        StrokeGuideStep(number: 4, position: Offset(0.50, 0.82), directionHint: '4 ➔'),
      ],
    ),
    'ㅅ': HangulCharacterDefinition(
      character: 'ㅅ',
      maxStrokesAllowed: 2,
      isOpenShape: true,
      expectedStart: Offset(0.50, 0.24),
      expectedEnd: Offset(0.74, 0.74),
      templatePaths: [
        [
          Offset(0.50, 0.24),
          Offset(0.38, 0.50),
          Offset(0.26, 0.74),
        ],
        [
          Offset(0.50, 0.44),
          Offset(0.62, 0.58),
          Offset(0.74, 0.74),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.50, 0.24),
          end: Offset(0.26, 0.74),
          segmentName: 'left mountain slope',
        ),
        CharacterSegment(
          start: Offset(0.50, 0.44),
          end: Offset(0.74, 0.74),
          segmentName: 'right mountain slope',
        ),
      ],
      mandatoryCorners: [
        Offset(0.50, 0.24),
      ],
      forbiddenCutZones: [
        Offset(0.50, 0.74),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.50, 0.16), directionHint: '1 ↙'),
        StrokeGuideStep(number: 2, position: Offset(0.68, 0.48), directionHint: '2 ↘'),
      ],
    ),
    'ㅇ': HangulCharacterDefinition(
      character: 'ㅇ',
      maxStrokesAllowed: 2,
      isOpenShape: false,
      expectedStart: Offset(0.50, 0.26),
      expectedEnd: Offset(0.50, 0.26),
      templatePaths: [
        [
          Offset(0.50, 0.26),
          Offset(0.32, 0.34),
          Offset(0.26, 0.50),
          Offset(0.32, 0.66),
          Offset(0.50, 0.74),
          Offset(0.68, 0.66),
          Offset(0.74, 0.50),
          Offset(0.68, 0.34),
          Offset(0.50, 0.26),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.50, 0.26),
          end: Offset(0.26, 0.50),
          segmentName: 'upper left arc',
        ),
        CharacterSegment(
          start: Offset(0.26, 0.50),
          end: Offset(0.50, 0.74),
          segmentName: 'lower left arc',
        ),
        CharacterSegment(
          start: Offset(0.50, 0.74),
          end: Offset(0.74, 0.50),
          segmentName: 'lower right arc',
        ),
        CharacterSegment(
          start: Offset(0.74, 0.50),
          end: Offset(0.50, 0.26),
          segmentName: 'upper right arc',
        ),
      ],
      mandatoryCorners: [],
      forbiddenCutZones: [
        Offset(0.50, 0.50),
      ],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.50, 0.16), directionHint: '1 ↺'),
      ],
    ),
    'ㅈ': HangulCharacterDefinition(
      character: 'ㅈ',
      maxStrokesAllowed: 3,
      isOpenShape: true,
      expectedStart: Offset(0.28, 0.28),
      expectedEnd: Offset(0.74, 0.74),
      templatePaths: [
        [
          Offset(0.28, 0.28),
          Offset(0.72, 0.28),
          Offset(0.48, 0.52),
          Offset(0.26, 0.74),
        ],
        [
          Offset(0.50, 0.48),
          Offset(0.74, 0.74),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.28, 0.28),
          end: Offset(0.72, 0.28),
          segmentName: 'top horizontal roof',
        ),
        CharacterSegment(
          start: Offset(0.72, 0.28),
          end: Offset(0.26, 0.74),
          segmentName: 'left diagonal leg',
        ),
        CharacterSegment(
          start: Offset(0.50, 0.48),
          end: Offset(0.74, 0.74),
          segmentName: 'right diagonal leg',
        ),
      ],
      mandatoryCorners: [
        Offset(0.72, 0.28),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.28, 0.20), directionHint: '1 ➔↙'),
        StrokeGuideStep(number: 2, position: Offset(0.68, 0.50), directionHint: '2 ↘'),
      ],
    ),
    'ㅋ': HangulCharacterDefinition(
      character: 'ㅋ',
      maxStrokesAllowed: 3,
      isOpenShape: true,
      expectedStart: Offset(0.28, 0.28),
      expectedEnd: Offset(0.72, 0.52),
      templatePaths: [
        [
          Offset(0.28, 0.28),
          Offset(0.72, 0.28),
          Offset(0.72, 0.74),
        ],
        [
          Offset(0.30, 0.50),
          Offset(0.72, 0.50),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.28, 0.28),
          end: Offset(0.72, 0.28),
          segmentName: 'top horizontal bar',
        ),
        CharacterSegment(
          start: Offset(0.72, 0.28),
          end: Offset(0.72, 0.74),
          segmentName: 'right vertical stem',
        ),
        CharacterSegment(
          start: Offset(0.30, 0.50),
          end: Offset(0.72, 0.50),
          segmentName: 'middle key bar',
        ),
      ],
      mandatoryCorners: [
        Offset(0.72, 0.28),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.28, 0.20), directionHint: '1 ➔↴'),
        StrokeGuideStep(number: 2, position: Offset(0.24, 0.50), directionHint: '2 ➔'),
      ],
    ),
    'ㅌ': HangulCharacterDefinition(
      character: 'ㅌ',
      maxStrokesAllowed: 4,
      isOpenShape: true,
      expectedStart: Offset(0.30, 0.26),
      expectedEnd: Offset(0.72, 0.74),
      templatePaths: [
        [
          Offset(0.30, 0.26),
          Offset(0.72, 0.26),
        ],
        [
          Offset(0.30, 0.50),
          Offset(0.68, 0.50),
        ],
        [
          Offset(0.30, 0.26),
          Offset(0.30, 0.74),
          Offset(0.72, 0.74),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.30, 0.26),
          end: Offset(0.72, 0.26),
          segmentName: 'top bar',
        ),
        CharacterSegment(
          start: Offset(0.30, 0.50),
          end: Offset(0.68, 0.50),
          segmentName: 'middle bar',
        ),
        CharacterSegment(
          start: Offset(0.30, 0.26),
          end: Offset(0.30, 0.74),
          segmentName: 'left vertical stem',
        ),
        CharacterSegment(
          start: Offset(0.30, 0.74),
          end: Offset(0.72, 0.74),
          segmentName: 'bottom bar',
        ),
      ],
      mandatoryCorners: [
        Offset(0.30, 0.74),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.30, 0.18), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.50, 0.42), directionHint: '2 ➔'),
        StrokeGuideStep(number: 3, position: Offset(0.20, 0.60), directionHint: '3 ↓➔'),
      ],
    ),
    'ㅍ': HangulCharacterDefinition(
      character: 'ㅍ',
      maxStrokesAllowed: 4,
      isOpenShape: true,
      expectedStart: Offset(0.26, 0.28),
      expectedEnd: Offset(0.74, 0.72),
      templatePaths: [
        [
          Offset(0.26, 0.28),
          Offset(0.74, 0.28),
        ],
        [
          Offset(0.38, 0.28),
          Offset(0.38, 0.72),
        ],
        [
          Offset(0.62, 0.28),
          Offset(0.62, 0.72),
        ],
        [
          Offset(0.24, 0.72),
          Offset(0.74, 0.72),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.26, 0.28),
          end: Offset(0.74, 0.28),
          segmentName: 'top roof bar',
        ),
        CharacterSegment(
          start: Offset(0.38, 0.28),
          end: Offset(0.38, 0.72),
          segmentName: 'left pillar',
        ),
        CharacterSegment(
          start: Offset(0.62, 0.28),
          end: Offset(0.62, 0.72),
          segmentName: 'right pillar',
        ),
        CharacterSegment(
          start: Offset(0.24, 0.72),
          end: Offset(0.74, 0.72),
          segmentName: 'bottom floor bar',
        ),
      ],
      mandatoryCorners: [],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.26, 0.20), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.30, 0.48), directionHint: '2 ↓'),
        StrokeGuideStep(number: 3, position: Offset(0.70, 0.48), directionHint: '3 ↓'),
        StrokeGuideStep(number: 4, position: Offset(0.50, 0.80), directionHint: '4 ➔'),
      ],
    ),
    'ㅊ': HangulCharacterDefinition(
      character: 'ㅊ',
      maxStrokesAllowed: 4,
      isOpenShape: true,
      expectedStart: Offset(0.42, 0.18),
      expectedEnd: Offset(0.74, 0.76),
      templatePaths: [
        [
          Offset(0.42, 0.18),
          Offset(0.58, 0.18),
        ],
        [
          Offset(0.28, 0.34),
          Offset(0.72, 0.34),
          Offset(0.48, 0.56),
          Offset(0.26, 0.76),
        ],
        [
          Offset(0.50, 0.52),
          Offset(0.74, 0.76),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.42, 0.18),
          end: Offset(0.58, 0.18),
          segmentName: 'top hat tick',
        ),
        CharacterSegment(
          start: Offset(0.28, 0.34),
          end: Offset(0.72, 0.34),
          segmentName: 'horizontal bar',
        ),
        CharacterSegment(
          start: Offset(0.72, 0.34),
          end: Offset(0.26, 0.76),
          segmentName: 'left leg',
        ),
        CharacterSegment(
          start: Offset(0.50, 0.52),
          end: Offset(0.74, 0.76),
          segmentName: 'right leg',
        ),
      ],
      mandatoryCorners: [
        Offset(0.72, 0.34),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.50, 0.10), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.24, 0.34), directionHint: '2 ➔↙'),
        StrokeGuideStep(number: 3, position: Offset(0.70, 0.56), directionHint: '3 ↘'),
      ],
    ),
    'ㅎ': HangulCharacterDefinition(
      character: 'ㅎ',
      maxStrokesAllowed: 4,
      isOpenShape: false,
      expectedStart: Offset(0.40, 0.18),
      expectedEnd: Offset(0.50, 0.46),
      templatePaths: [
        [
          Offset(0.40, 0.18),
          Offset(0.60, 0.18),
        ],
        [
          Offset(0.24, 0.32),
          Offset(0.76, 0.32),
        ],
        [
          Offset(0.50, 0.46),
          Offset(0.34, 0.54),
          Offset(0.34, 0.68),
          Offset(0.50, 0.76),
          Offset(0.66, 0.68),
          Offset(0.66, 0.54),
          Offset(0.50, 0.46),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.40, 0.18),
          end: Offset(0.60, 0.18),
          segmentName: 'top hat crown',
        ),
        CharacterSegment(
          start: Offset(0.24, 0.32),
          end: Offset(0.76, 0.32),
          segmentName: 'hat brim',
        ),
        CharacterSegment(
          start: Offset(0.50, 0.46),
          end: Offset(0.34, 0.68),
          segmentName: 'left circle side',
        ),
        CharacterSegment(
          start: Offset(0.50, 0.76),
          end: Offset(0.66, 0.54),
          segmentName: 'right circle side',
        ),
      ],
      mandatoryCorners: [],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.50, 0.10), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.24, 0.26), directionHint: '2 ➔'),
        StrokeGuideStep(number: 3, position: Offset(0.50, 0.84), directionHint: '3 ↺'),
      ],
    ),
    'ㅑ': HangulCharacterDefinition(
      character: 'ㅑ',
      maxStrokesAllowed: 3,
      isOpenShape: true,
      expectedStart: Offset(0.44, 0.20),
      expectedEnd: Offset(0.74, 0.60),
      templatePaths: [
        [
          Offset(0.44, 0.20),
          Offset(0.44, 0.50),
          Offset(0.44, 0.80),
        ],
        [
          Offset(0.44, 0.38),
          Offset(0.74, 0.38),
        ],
        [
          Offset(0.44, 0.60),
          Offset(0.74, 0.60),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.44, 0.20),
          end: Offset(0.44, 0.80),
          segmentName: 'vertical stem',
        ),
        CharacterSegment(
          start: Offset(0.44, 0.38),
          end: Offset(0.74, 0.38),
          segmentName: 'upper right branch',
        ),
        CharacterSegment(
          start: Offset(0.44, 0.60),
          end: Offset(0.74, 0.60),
          segmentName: 'lower right branch',
        ),
      ],
      mandatoryCorners: [
        Offset(0.44, 0.38),
        Offset(0.44, 0.60),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.44, 0.12), directionHint: '1 ↓'),
        StrokeGuideStep(number: 2, position: Offset(0.74, 0.30), directionHint: '2 ➔'),
        StrokeGuideStep(number: 3, position: Offset(0.74, 0.68), directionHint: '3 ➔'),
      ],
    ),
    'ㅛ': HangulCharacterDefinition(
      character: 'ㅛ',
      maxStrokesAllowed: 3,
      isOpenShape: true,
      expectedStart: Offset(0.38, 0.24),
      expectedEnd: Offset(0.76, 0.60),
      templatePaths: [
        [
          Offset(0.38, 0.24),
          Offset(0.38, 0.60),
        ],
        [
          Offset(0.62, 0.24),
          Offset(0.62, 0.60),
        ],
        [
          Offset(0.24, 0.60),
          Offset(0.50, 0.60),
          Offset(0.76, 0.60),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.38, 0.24),
          end: Offset(0.38, 0.60),
          segmentName: 'left vertical stem',
        ),
        CharacterSegment(
          start: Offset(0.62, 0.24),
          end: Offset(0.62, 0.60),
          segmentName: 'right vertical stem',
        ),
        CharacterSegment(
          start: Offset(0.24, 0.60),
          end: Offset(0.76, 0.60),
          segmentName: 'horizontal base',
        ),
      ],
      mandatoryCorners: [],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.38, 0.16), directionHint: '1 ↓'),
        StrokeGuideStep(number: 2, position: Offset(0.62, 0.16), directionHint: '2 ↓'),
        StrokeGuideStep(number: 3, position: Offset(0.24, 0.68), directionHint: '3 ➔'),
      ],
    ),
    'ㅐ': HangulCharacterDefinition(
      character: 'ㅐ',
      maxStrokesAllowed: 3,
      isOpenShape: true,
      expectedStart: Offset(0.36, 0.20),
      expectedEnd: Offset(0.66, 0.80),
      templatePaths: [
        [
          Offset(0.36, 0.20),
          Offset(0.36, 0.80),
        ],
        [
          Offset(0.36, 0.50),
          Offset(0.66, 0.50),
        ],
        [
          Offset(0.66, 0.20),
          Offset(0.66, 0.80),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.36, 0.20),
          end: Offset(0.36, 0.80),
          segmentName: 'left vertical stem',
        ),
        CharacterSegment(
          start: Offset(0.36, 0.50),
          end: Offset(0.66, 0.50),
          segmentName: 'middle bridge',
        ),
        CharacterSegment(
          start: Offset(0.66, 0.20),
          end: Offset(0.66, 0.80),
          segmentName: 'right vertical stem',
        ),
      ],
      mandatoryCorners: [
        Offset(0.36, 0.50),
        Offset(0.66, 0.50),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.36, 0.12), directionHint: '1 ↓'),
        StrokeGuideStep(number: 2, position: Offset(0.50, 0.42), directionHint: '2 ➔'),
        StrokeGuideStep(number: 3, position: Offset(0.66, 0.12), directionHint: '3 ↓'),
      ],
    ),
    'ㅔ': HangulCharacterDefinition(
      character: 'ㅔ',
      maxStrokesAllowed: 3,
      isOpenShape: true,
      expectedStart: Offset(0.22, 0.50),
      expectedEnd: Offset(0.70, 0.80),
      templatePaths: [
        [
          Offset(0.22, 0.50),
          Offset(0.48, 0.50),
        ],
        [
          Offset(0.48, 0.20),
          Offset(0.48, 0.80),
        ],
        [
          Offset(0.70, 0.20),
          Offset(0.70, 0.80),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.22, 0.50),
          end: Offset(0.48, 0.50),
          segmentName: 'left horizontal dash',
        ),
        CharacterSegment(
          start: Offset(0.48, 0.20),
          end: Offset(0.48, 0.80),
          segmentName: 'inner vertical stem',
        ),
        CharacterSegment(
          start: Offset(0.70, 0.20),
          end: Offset(0.70, 0.80),
          segmentName: 'outer vertical stem',
        ),
      ],
      mandatoryCorners: [
        Offset(0.48, 0.50),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.22, 0.42), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.48, 0.12), directionHint: '2 ↓'),
        StrokeGuideStep(number: 3, position: Offset(0.70, 0.12), directionHint: '3 ↓'),
      ],
    ),
    'ㅘ': HangulCharacterDefinition(
      character: 'ㅘ',
      maxStrokesAllowed: 4,
      isOpenShape: true,
      expectedStart: Offset(0.34, 0.30),
      expectedEnd: Offset(0.84, 0.50),
      templatePaths: [
        [
          Offset(0.34, 0.30),
          Offset(0.34, 0.62),
        ],
        [
          Offset(0.16, 0.62),
          Offset(0.52, 0.62),
        ],
        [
          Offset(0.64, 0.18),
          Offset(0.64, 0.82),
        ],
        [
          Offset(0.64, 0.50),
          Offset(0.84, 0.50),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.34, 0.30),
          end: Offset(0.34, 0.62),
          segmentName: 'left o stem',
        ),
        CharacterSegment(
          start: Offset(0.16, 0.62),
          end: Offset(0.52, 0.62),
          segmentName: 'left o base',
        ),
        CharacterSegment(
          start: Offset(0.64, 0.18),
          end: Offset(0.64, 0.82),
          segmentName: 'right vertical stem',
        ),
        CharacterSegment(
          start: Offset(0.64, 0.50),
          end: Offset(0.84, 0.50),
          segmentName: 'right branch',
        ),
      ],
      mandatoryCorners: [
        Offset(0.34, 0.62),
        Offset(0.64, 0.50),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.34, 0.22), directionHint: '1 ↓'),
        StrokeGuideStep(number: 2, position: Offset(0.16, 0.70), directionHint: '2 ➔'),
        StrokeGuideStep(number: 3, position: Offset(0.64, 0.10), directionHint: '3 ↓'),
        StrokeGuideStep(number: 4, position: Offset(0.84, 0.42), directionHint: '4 ➔'),
      ],
    ),
    'ㅝ': HangulCharacterDefinition(
      character: 'ㅝ',
      maxStrokesAllowed: 4,
      isOpenShape: true,
      expectedStart: Offset(0.16, 0.38),
      expectedEnd: Offset(0.74, 0.82),
      templatePaths: [
        [
          Offset(0.16, 0.38),
          Offset(0.54, 0.38),
        ],
        [
          Offset(0.35, 0.38),
          Offset(0.35, 0.72),
        ],
        [
          Offset(0.54, 0.56),
          Offset(0.74, 0.56),
        ],
        [
          Offset(0.74, 0.18),
          Offset(0.74, 0.82),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.16, 0.38),
          end: Offset(0.54, 0.38),
          segmentName: 'u horizontal bar',
        ),
        CharacterSegment(
          start: Offset(0.35, 0.38),
          end: Offset(0.35, 0.72),
          segmentName: 'u downward stem',
        ),
        CharacterSegment(
          start: Offset(0.54, 0.56),
          end: Offset(0.74, 0.56),
          segmentName: 'eo inward bar',
        ),
        CharacterSegment(
          start: Offset(0.74, 0.18),
          end: Offset(0.74, 0.82),
          segmentName: 'right vertical stem',
        ),
      ],
      mandatoryCorners: [
        Offset(0.35, 0.38),
        Offset(0.74, 0.56),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.16, 0.30), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.35, 0.80), directionHint: '2 ↓'),
        StrokeGuideStep(number: 3, position: Offset(0.54, 0.48), directionHint: '3 ➔'),
        StrokeGuideStep(number: 4, position: Offset(0.74, 0.10), directionHint: '4 ↓'),
      ],
    ),
    'ㅟ': HangulCharacterDefinition(
      character: 'ㅟ',
      maxStrokesAllowed: 3,
      isOpenShape: true,
      expectedStart: Offset(0.18, 0.42),
      expectedEnd: Offset(0.72, 0.82),
      templatePaths: [
        [
          Offset(0.18, 0.42),
          Offset(0.56, 0.42),
        ],
        [
          Offset(0.37, 0.42),
          Offset(0.37, 0.76),
        ],
        [
          Offset(0.72, 0.18),
          Offset(0.72, 0.82),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.18, 0.42),
          end: Offset(0.56, 0.42),
          segmentName: 'horizontal u bar',
        ),
        CharacterSegment(
          start: Offset(0.37, 0.42),
          end: Offset(0.37, 0.76),
          segmentName: 'downward u stem',
        ),
        CharacterSegment(
          start: Offset(0.72, 0.18),
          end: Offset(0.72, 0.82),
          segmentName: 'right vertical stem',
        ),
      ],
      mandatoryCorners: [
        Offset(0.37, 0.42),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.18, 0.34), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.37, 0.84), directionHint: '2 ↓'),
        StrokeGuideStep(number: 3, position: Offset(0.72, 0.10), directionHint: '3 ↓'),
      ],
    ),
    'ㅢ': HangulCharacterDefinition(
      character: 'ㅢ',
      maxStrokesAllowed: 2,
      isOpenShape: true,
      expectedStart: Offset(0.20, 0.56),
      expectedEnd: Offset(0.72, 0.82),
      templatePaths: [
        [
          Offset(0.20, 0.56),
          Offset(0.58, 0.56),
        ],
        [
          Offset(0.72, 0.18),
          Offset(0.72, 0.82),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.20, 0.56),
          end: Offset(0.58, 0.56),
          segmentName: 'horizontal eu bar',
        ),
        CharacterSegment(
          start: Offset(0.72, 0.18),
          end: Offset(0.72, 0.82),
          segmentName: 'vertical i stem',
        ),
      ],
      mandatoryCorners: [],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.20, 0.48), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.72, 0.10), directionHint: '2 ↓'),
      ],
    ),
    'ㄲ': HangulCharacterDefinition(
      character: 'ㄲ',
      maxStrokesAllowed: 4,
      isOpenShape: true,
      expectedStart: Offset(0.18, 0.30),
      expectedEnd: Offset(0.80, 0.72),
      templatePaths: [
        [
          Offset(0.18, 0.30),
          Offset(0.44, 0.30),
          Offset(0.44, 0.72),
        ],
        [
          Offset(0.54, 0.30),
          Offset(0.80, 0.30),
          Offset(0.80, 0.72),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.18, 0.30),
          end: Offset(0.44, 0.30),
          segmentName: 'first top bar',
        ),
        CharacterSegment(
          start: Offset(0.44, 0.30),
          end: Offset(0.44, 0.72),
          segmentName: 'first vertical drop',
        ),
        CharacterSegment(
          start: Offset(0.54, 0.30),
          end: Offset(0.80, 0.30),
          segmentName: 'second top bar',
        ),
        CharacterSegment(
          start: Offset(0.80, 0.30),
          end: Offset(0.80, 0.72),
          segmentName: 'second vertical drop',
        ),
      ],
      mandatoryCorners: [
        Offset(0.44, 0.30),
        Offset(0.80, 0.30),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.18, 0.22), directionHint: '1 ➔↴'),
        StrokeGuideStep(number: 2, position: Offset(0.54, 0.22), directionHint: '2 ➔↴'),
      ],
    ),
    'ㄸ': HangulCharacterDefinition(
      character: 'ㄸ',
      maxStrokesAllowed: 6,
      isOpenShape: true,
      expectedStart: Offset(0.18, 0.30),
      expectedEnd: Offset(0.82, 0.72),
      templatePaths: [
        [
          Offset(0.18, 0.30),
          Offset(0.44, 0.30),
        ],
        [
          Offset(0.18, 0.30),
          Offset(0.18, 0.72),
          Offset(0.44, 0.72),
        ],
        [
          Offset(0.56, 0.30),
          Offset(0.82, 0.30),
        ],
        [
          Offset(0.56, 0.30),
          Offset(0.56, 0.72),
          Offset(0.82, 0.72),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.18, 0.30),
          end: Offset(0.44, 0.30),
          segmentName: 'first top bar',
        ),
        CharacterSegment(
          start: Offset(0.18, 0.30),
          end: Offset(0.18, 0.72),
          segmentName: 'first left stem',
        ),
        CharacterSegment(
          start: Offset(0.18, 0.72),
          end: Offset(0.44, 0.72),
          segmentName: 'first bottom bar',
        ),
        CharacterSegment(
          start: Offset(0.56, 0.30),
          end: Offset(0.82, 0.30),
          segmentName: 'second top bar',
        ),
        CharacterSegment(
          start: Offset(0.56, 0.30),
          end: Offset(0.56, 0.72),
          segmentName: 'second left stem',
        ),
        CharacterSegment(
          start: Offset(0.56, 0.72),
          end: Offset(0.82, 0.72),
          segmentName: 'second bottom bar',
        ),
      ],
      mandatoryCorners: [
        Offset(0.18, 0.72),
        Offset(0.56, 0.72),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.18, 0.22), directionHint: '1 ➔'),
        StrokeGuideStep(number: 2, position: Offset(0.18, 0.80), directionHint: '2 ↓➔'),
        StrokeGuideStep(number: 3, position: Offset(0.56, 0.22), directionHint: '3 ➔'),
        StrokeGuideStep(number: 4, position: Offset(0.56, 0.80), directionHint: '4 ↓➔'),
      ],
    ),
    'ㅃ': HangulCharacterDefinition(
      character: 'ㅃ',
      maxStrokesAllowed: 8,
      isOpenShape: false,
      expectedStart: Offset(0.18, 0.26),
      expectedEnd: Offset(0.82, 0.74),
      templatePaths: [
        [
          Offset(0.18, 0.26),
          Offset(0.18, 0.74),
        ],
        [
          Offset(0.44, 0.26),
          Offset(0.44, 0.74),
        ],
        [
          Offset(0.18, 0.50),
          Offset(0.44, 0.50),
        ],
        [
          Offset(0.18, 0.74),
          Offset(0.44, 0.74),
        ],
        [
          Offset(0.56, 0.26),
          Offset(0.56, 0.74),
        ],
        [
          Offset(0.82, 0.26),
          Offset(0.82, 0.74),
        ],
        [
          Offset(0.56, 0.50),
          Offset(0.82, 0.50),
        ],
        [
          Offset(0.56, 0.74),
          Offset(0.82, 0.74),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.18, 0.26),
          end: Offset(0.18, 0.74),
          segmentName: 'first left wall',
        ),
        CharacterSegment(
          start: Offset(0.44, 0.26),
          end: Offset(0.44, 0.74),
          segmentName: 'first right wall',
        ),
        CharacterSegment(
          start: Offset(0.18, 0.74),
          end: Offset(0.44, 0.74),
          segmentName: 'first base',
        ),
        CharacterSegment(
          start: Offset(0.56, 0.26),
          end: Offset(0.56, 0.74),
          segmentName: 'second left wall',
        ),
        CharacterSegment(
          start: Offset(0.82, 0.26),
          end: Offset(0.82, 0.74),
          segmentName: 'second right wall',
        ),
        CharacterSegment(
          start: Offset(0.56, 0.74),
          end: Offset(0.82, 0.74),
          segmentName: 'second base',
        ),
      ],
      mandatoryCorners: [
        Offset(0.18, 0.74),
        Offset(0.56, 0.74),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.18, 0.18), directionHint: '1 ↓'),
        StrokeGuideStep(number: 2, position: Offset(0.44, 0.18), directionHint: '2 ↓'),
        StrokeGuideStep(number: 3, position: Offset(0.56, 0.18), directionHint: '3 ↓'),
        StrokeGuideStep(number: 4, position: Offset(0.82, 0.18), directionHint: '4 ↓'),
      ],
    ),
    'ㅆ': HangulCharacterDefinition(
      character: 'ㅆ',
      maxStrokesAllowed: 4,
      isOpenShape: true,
      expectedStart: Offset(0.32, 0.26),
      expectedEnd: Offset(0.84, 0.74),
      templatePaths: [
        [
          Offset(0.32, 0.26),
          Offset(0.16, 0.74),
        ],
        [
          Offset(0.32, 0.46),
          Offset(0.46, 0.74),
        ],
        [
          Offset(0.68, 0.26),
          Offset(0.52, 0.74),
        ],
        [
          Offset(0.68, 0.46),
          Offset(0.84, 0.74),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.32, 0.26),
          end: Offset(0.16, 0.74),
          segmentName: 'first left slope',
        ),
        CharacterSegment(
          start: Offset(0.32, 0.46),
          end: Offset(0.46, 0.74),
          segmentName: 'first right slope',
        ),
        CharacterSegment(
          start: Offset(0.68, 0.26),
          end: Offset(0.52, 0.74),
          segmentName: 'second left slope',
        ),
        CharacterSegment(
          start: Offset(0.68, 0.46),
          end: Offset(0.84, 0.74),
          segmentName: 'second right slope',
        ),
      ],
      mandatoryCorners: [
        Offset(0.32, 0.26),
        Offset(0.68, 0.26),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.32, 0.18), directionHint: '1 ↙'),
        StrokeGuideStep(number: 2, position: Offset(0.44, 0.48), directionHint: '2 ↘'),
        StrokeGuideStep(number: 3, position: Offset(0.68, 0.18), directionHint: '3 ↙'),
        StrokeGuideStep(number: 4, position: Offset(0.82, 0.48), directionHint: '4 ↘'),
      ],
    ),
    'ㅉ': HangulCharacterDefinition(
      character: 'ㅉ',
      maxStrokesAllowed: 6,
      isOpenShape: true,
      expectedStart: Offset(0.16, 0.28),
      expectedEnd: Offset(0.84, 0.74),
      templatePaths: [
        [
          Offset(0.16, 0.28),
          Offset(0.46, 0.28),
          Offset(0.16, 0.74),
        ],
        [
          Offset(0.32, 0.50),
          Offset(0.46, 0.74),
        ],
        [
          Offset(0.54, 0.28),
          Offset(0.84, 0.28),
          Offset(0.54, 0.74),
        ],
        [
          Offset(0.70, 0.50),
          Offset(0.84, 0.74),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.16, 0.28),
          end: Offset(0.46, 0.28),
          segmentName: 'first roof',
        ),
        CharacterSegment(
          start: Offset(0.46, 0.28),
          end: Offset(0.16, 0.74),
          segmentName: 'first left leg',
        ),
        CharacterSegment(
          start: Offset(0.54, 0.28),
          end: Offset(0.84, 0.28),
          segmentName: 'second roof',
        ),
        CharacterSegment(
          start: Offset(0.84, 0.28),
          end: Offset(0.54, 0.74),
          segmentName: 'second left leg',
        ),
      ],
      mandatoryCorners: [
        Offset(0.46, 0.28),
        Offset(0.84, 0.28),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.16, 0.20), directionHint: '1 ➔↙'),
        StrokeGuideStep(number: 2, position: Offset(0.54, 0.20), directionHint: '2 ➔↙'),
      ],
    ),
    '산': HangulCharacterDefinition(
      character: '산',
      maxStrokesAllowed: 6,
      isOpenShape: true,
      expectedStart: Offset(0.34, 0.18),
      expectedEnd: Offset(0.74, 0.84),
      templatePaths: [
        [
          Offset(0.34, 0.18),
          Offset(0.18, 0.52),
        ],
        [
          Offset(0.34, 0.34),
          Offset(0.50, 0.52),
        ],
        [
          Offset(0.64, 0.16),
          Offset(0.64, 0.56),
        ],
        [
          Offset(0.64, 0.36),
          Offset(0.82, 0.36),
        ],
        [
          Offset(0.28, 0.62),
          Offset(0.28, 0.84),
          Offset(0.74, 0.84),
        ],
      ],
      segments: [
        CharacterSegment(
          start: Offset(0.34, 0.18),
          end: Offset(0.18, 0.52),
          segmentName: 'top consonant left slope',
        ),
        CharacterSegment(
          start: Offset(0.34, 0.34),
          end: Offset(0.50, 0.52),
          segmentName: 'top consonant right slope',
        ),
        CharacterSegment(
          start: Offset(0.64, 0.16),
          end: Offset(0.64, 0.56),
          segmentName: 'vowel vertical stem',
        ),
        CharacterSegment(
          start: Offset(0.64, 0.36),
          end: Offset(0.82, 0.36),
          segmentName: 'vowel branch',
        ),
        CharacterSegment(
          start: Offset(0.28, 0.62),
          end: Offset(0.28, 0.84),
          segmentName: 'batchim vertical drop',
        ),
        CharacterSegment(
          start: Offset(0.28, 0.84),
          end: Offset(0.74, 0.84),
          segmentName: 'batchim bottom bar',
        ),
      ],
      mandatoryCorners: [
        Offset(0.28, 0.84),
      ],
      forbiddenCutZones: [],
      guideSteps: [
        StrokeGuideStep(number: 1, position: Offset(0.34, 0.10), directionHint: '1 ↙'),
        StrokeGuideStep(number: 2, position: Offset(0.48, 0.32), directionHint: '2 ↘'),
        StrokeGuideStep(number: 3, position: Offset(0.64, 0.10), directionHint: '3 ↓'),
        StrokeGuideStep(number: 4, position: Offset(0.82, 0.28), directionHint: '4 ➔'),
        StrokeGuideStep(number: 5, position: Offset(0.20, 0.72), directionHint: '5 ↓➔'),
      ],
    ),
  };

  static HangulCharacterDefinition getDefinition(String char) {
    return _definitions[char] ??
        HangulCharacterDefinition(
          character: char,
          maxStrokesAllowed: 3,
          isOpenShape: true,
          expectedStart: const Offset(0.35, 0.35),
          expectedEnd: const Offset(0.65, 0.65),
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

  /// Strict handwriting verifier preventing coloring/scribbling, dot-skips, loop exploits, and backwards strokes.
  /// When [freehandMode] is true (e.g. during blank quizzes without stencils), coordinates are
  /// normalized relative to the user's drawn bounding box so that the evaluation is scale and
  /// translation invariant, while still strictly enforcing character geometry, stroke count,
  /// stroke direction, corners, and segments.
  static StrokeEvaluationResult evaluate({
    required String character,
    required List<List<Offset>> strokes,
    required Size canvasSize,
    bool freehandMode = false,
  }) {
    final def = getDefinition(character);

    // Filter out accidental empty sub-strokes
    final activeStrokes = strokes.where((s) => s.isNotEmpty).toList();

    // 1. Dotted Tap Exploit Check
    if (activeStrokes.length > def.maxStrokesAllowed) {
      return StrokeEvaluationResult(
        isAccurate: false,
        accuracyScore: 0.2,
        feedbackMessage: freehandMode
            ? 'Write in smooth, continuous stroke(s)! Don\'t tap dots 😊'
            : 'Trace in smooth, continuous stroke(s)! Don\'t lift your finger to tap dots 😊',
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

    // Convert raw points to normalized canvas space (0.0 to 1.0)
    final rawNormPoints = allPoints
        .map((p) => Offset(p.dx / canvasSize.width, p.dy / canvasSize.height))
        .toList();

    // Calculate user's drawn bounding box
    double uMinX = double.infinity, uMaxX = -double.infinity;
    double uMinY = double.infinity, uMaxY = -double.infinity;
    for (final p in rawNormPoints) {
      if (p.dx < uMinX) uMinX = p.dx;
      if (p.dx > uMaxX) uMaxX = p.dx;
      if (p.dy < uMinY) uMinY = p.dy;
      if (p.dy > uMaxY) uMaxY = p.dy;
    }
    final uWidth = uMaxX - uMinX;
    final uHeight = uMaxY - uMinY;

    if (freehandMode && (uWidth < 0.05 && uHeight < 0.05)) {
      return StrokeEvaluationResult(
        isAccurate: false,
        accuracyScore: 0.1,
        feedbackMessage: 'Your drawing is too small! Write "$character" larger so it is clearly readable 😊',
      );
    }

    // Calculate template canonical bounding box
    final allTemplatePoints = def.templatePaths.expand((p) => p).toList();
    double tMinX = double.infinity, tMaxX = -double.infinity;
    double tMinY = double.infinity, tMaxY = -double.infinity;
    for (final p in allTemplatePoints) {
      if (p.dx < tMinX) tMinX = p.dx;
      if (p.dx > tMaxX) tMaxX = p.dx;
      if (p.dy < tMinY) tMinY = p.dy;
      if (p.dy > tMaxY) tMaxY = p.dy;
    }
    final tWidth = (tMaxX - tMinX).clamp(0.10, 1.0);
    final tHeight = (tMaxY - tMinY).clamp(0.10, 1.0);
    final tCenterX = (tMinX + tMaxX) / 2;
    final tCenterY = (tMinY + tMaxY) / 2;
    final uCenterX = (uMinX + uMaxX) / 2;
    final uCenterY = (uMinY + uMaxY) / 2;

    // Translation & scale alignment parameters
    double scaleX = 1.0;
    double scaleY = 1.0;
    if (freehandMode) {
      final tAspect = tWidth / tHeight;
      final uAspect = (uWidth > 0.01 && uHeight > 0.01) ? (uWidth / uHeight) : tAspect;
      // Allow natural human handwriting aspect-ratio deviation (0.45x to 2.2x)
      final aspectDeviation = (uAspect / tAspect).clamp(0.45, 2.2);

      if (tHeight >= tWidth) {
        scaleY = (uHeight > 0.02) ? (tHeight / uHeight) : 1.0;
        scaleX = scaleY * tAspect * aspectDeviation;
      } else {
        scaleX = (uWidth > 0.02) ? (tWidth / uWidth) : 1.0;
        scaleY = (scaleX / tAspect) / aspectDeviation;
      }

      scaleX = scaleX.clamp(0.3, 5.0);
      scaleY = scaleY.clamp(0.3, 5.0);
    }

    Offset alignPoint(Offset p) {
      if (!freehandMode) return p;
      return Offset(
        tCenterX + (p.dx - uCenterX) * scaleX,
        tCenterY + (p.dy - uCenterY) * scaleY,
      );
    }

    // Points normalized and aligned with the canonical template
    final normPoints = rawNormPoints.map(alignPoint).toList();

    // 2. Closed Loop Exploit Check (Check before endpoints so loops get immediate specific feedback)
    if (def.isOpenShape) {
      for (final stroke in activeStrokes) {
        if (stroke.length >= 8) {
          final first = alignPoint(Offset(stroke.first.dx / canvasSize.width, stroke.first.dy / canvasSize.height));
          final last = alignPoint(Offset(stroke.last.dx / canvasSize.width, stroke.last.dy / canvasSize.height));
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

    // 3. Anti-Coloring / Anti-Scribble Path Length Check
    double idealLength = 0.0;
    for (final seg in def.segments) {
      idealLength += (seg.end - seg.start).distance;
    }

    double totalDrawnLength = 0.0;
    for (final stroke in activeStrokes) {
      for (int i = 1; i < stroke.length; i++) {
        final p1 = alignPoint(Offset(stroke[i - 1].dx / canvasSize.width, stroke[i - 1].dy / canvasSize.height));
        final p2 = alignPoint(Offset(stroke[i].dx / canvasSize.width, stroke[i].dy / canvasSize.height));
        totalDrawnLength += (p2 - p1).distance;
      }
    }

    final maxAllowedLengthMultiplier = freehandMode ? 1.95 : 1.55;
    if (totalDrawnLength > idealLength * maxAllowedLengthMultiplier) {
      return const StrokeEvaluationResult(
        isAccurate: false,
        accuracyScore: 0.35,
        feedbackMessage:
            'Don\'t color back-and-forth! Write with smooth, clean strokes like a pen.',
      );
    }

    // 4. Direction Oscillations (Zigzag Comb Detector) & Stationary Scrubbing (Blob Detector)
    for (final stroke in activeStrokes) {
      if (stroke.length < 6) continue;
      final normStroke = stroke
          .map((p) => alignPoint(Offset(p.dx / canvasSize.width, p.dy / canvasSize.height)))
          .toList();

      // Spatially resample with step 0.02 (approx 6-8px) to eliminate high-frequency digitizer jitter
      final resampled = <Offset>[normStroke.first];
      for (final p in normStroke) {
        if ((p - resampled.last).distance >= 0.02) {
          resampled.add(p);
        }
      }
      if ((normStroke.last - resampled.last).distance > 0.008) {
        resampled.add(normStroke.last);
      }

      if (resampled.length >= 6) {
        // A. Blob / Stationary scrubbing detector:
        for (int i = 0; i <= resampled.length - 6; i++) {
          final windowStart = resampled[i];
          final windowEnd = resampled[i + 5];
          if ((windowStart - windowEnd).distance < 0.035) {
            return StrokeEvaluationResult(
              isAccurate: false,
              accuracyScore: 0.35,
              feedbackMessage:
                  'Don\'t scrub or color in one spot! Glide smoothly to write "$character".',
            );
          }
        }

        // B. Reversal counter (Zigzag teeth)
        int xReversals = 0;
        int yReversals = 0;
        double? lastDxSign;
        double? lastDySign;

        for (int i = 1; i < resampled.length; i++) {
          final d = resampled[i] - resampled[i - 1];
          if (d.dx.abs() > 0.012) {
            final s = d.dx.sign;
            if (lastDxSign != null && s != lastDxSign) {
              xReversals++;
            }
            lastDxSign = s;
          }
          if (d.dy.abs() > 0.012) {
            final s = d.dy.sign;
            if (lastDySign != null && s != lastDySign) {
              yReversals++;
            }
            lastDySign = s;
          }
        }

        final maxReversals = freehandMode ? 4 : 3;
        if (xReversals > maxReversals || yReversals > maxReversals) {
          return const StrokeEvaluationResult(
            isAccurate: false,
            accuracyScore: 0.35,
            feedbackMessage:
                'Zigzag scribble detected! Glide forward smoothly without scrubbing.',
          );
        }
      }
    }

    // 5. Stroke Flow & Direction Check (Start & End Points)
    final firstPoint = normPoints.first;
    final lastPoint = normPoints.last;

    final startEndTolerance = freehandMode ? 0.32 : 0.19;

    final validStarts = [def.expectedStart];
    if (freehandMode) {
      for (final p in def.templatePaths) {
        if (p.isNotEmpty) validStarts.add(p.first);
      }
    }

    bool startValid = false;
    for (final start in validStarts) {
      if ((firstPoint - start).distance <= startEndTolerance) {
        startValid = true;
        break;
      }
    }

    if (!startValid) {
      return StrokeEvaluationResult(
        isAccurate: false,
        accuracyScore: 0.4,
        feedbackMessage: freehandMode
            ? 'Start writing "$character" from the correct starting position!'
            : 'Start writing at guide marker (1) and follow the arrow!',
      );
    }

    final validEnds = [def.expectedEnd];
    if (freehandMode) {
      for (final p in def.templatePaths) {
        if (p.isNotEmpty) validEnds.add(p.last);
      }
    }

    bool endValid = false;
    for (final end in validEnds) {
      if ((lastPoint - end).distance <= startEndTolerance) {
        endValid = true;
        break;
      }
    }

    if (!endValid) {
      return StrokeEvaluationResult(
        isAccurate: false,
        accuracyScore: 0.4,
        feedbackMessage: freehandMode
            ? 'Follow the stroke all the way to the end of "$character"!'
            : 'Follow the stroke all the way to the end of "$character"!',
      );
    }

    // 6. Mandatory Corner Check
    final cornerTolerance = freehandMode ? 0.22 : 0.11;
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

    // 7. Forbidden Cut Zone Check (Diagonal Hypotenuse)
    final cutZoneTolerance = freehandMode ? 0.080 : 0.085;
    final maxCutPoints = freehandMode ? 4 : 3;
    for (final cutZone in def.forbiddenCutZones) {
      int cutPoints = 0;
      for (final pt in normPoints) {
        if ((pt - cutZone).distance <= cutZoneTolerance) {
          cutPoints++;
        }
      }
      if (cutPoints >= maxCutPoints) {
        return StrokeEvaluationResult(
          isAccurate: false,
          accuracyScore: 0.35,
          feedbackMessage:
              'Diagonal shortcut detected! Follow the outside right angle of "$character".',
        );
      }
    }

    // 8. Segment-by-Segment Completeness Check
    final segmentTolerance = freehandMode ? 0.18 : 0.095;
    final minCoverage = freehandMode ? 0.50 : 0.65;
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
      if (segmentCoverage < minCoverage) {
        return StrokeEvaluationResult(
          isAccurate: false,
          accuracyScore: segmentCoverage,
          feedbackMessage: freehandMode
              ? 'Incomplete! Make sure to write the full shape of "$character".'
              : 'Incomplete! You missed the ${segment.segmentName} of "$character". Trace both sides fully!',
        );
      }
    }

    // 9. Stray points penalty
    final allCheckpoints = def.templatePaths.expand((p) => p).toList();
    final maxStrayDistance = freehandMode ? 0.30 : 0.20;
    final maxStrayRatio = freehandMode ? 0.38 : 0.30;
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
    if (strayRatio > maxStrayRatio) {
      return StrokeEvaluationResult(
        isAccurate: false,
        accuracyScore: 0.4,
        feedbackMessage: freehandMode
            ? 'Too many extra or stray marks. Draw cleanly when writing "$character"!'
            : 'Too many stray lines outside the stencil. Stay inside the grey track of "$character"!',
      );
    }

    return StrokeEvaluationResult(
      isAccurate: true,
      accuracyScore: 0.95,
      feedbackMessage: 'Beautiful! You wrote "$character" with full strokes & clean corners! ✨',
    );
  }
}
