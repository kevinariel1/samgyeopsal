import 'dart:convert';
import 'unit_model.dart';

class UserProgressModel {
  final Set<String> completedLessonIds;
  final Map<String, int> unitQuizScores; // unitId -> score percentage
  final int streakDays;
  final int totalXp;
  final String lastActiveDate;

  const UserProgressModel({
    required this.completedLessonIds,
    required this.unitQuizScores,
    this.streakDays = 1,
    this.totalXp = 0,
    required this.lastActiveDate,
  });

  factory UserProgressModel.initial() {
    return UserProgressModel(
      completedLessonIds: {},
      unitQuizScores: {},
      streakDays: 1,
      totalXp: 0,
      lastActiveDate: DateTime.now().toIso8601String().substring(0, 10),
    );
  }

  bool isLessonCompleted(String lessonId) {
    return completedLessonIds.contains(lessonId);
  }

  bool isUnitPassed(String unitId, [int passingScore = 80]) {
    final score = unitQuizScores[unitId];
    return score != null && score >= passingScore;
  }

  /// Determines if unit is unlocked.
  /// Unit 1 (or any unit with unlockRequirement == 0) is always unlocked.
  /// Otherwise, previous unit must have its quiz passed >= 80%.
  bool isUnitUnlocked(UnitModel unit, List<UnitModel> allUnits) {
    if (unit.unlockRequirement == 0 || unit.order <= 1) return true;
    final prevUnit = allUnits.where((u) => u.order == unit.order - 1).firstOrNull;
    if (prevUnit == null) return true;
    return isUnitPassed(prevUnit.id, prevUnit.quiz?.passingScorePercent ?? 80);
  }

  int get completedLessonsCount => completedLessonIds.length;

  int get passedUnitsCount => unitQuizScores.values.where((score) => score >= 80).length;

  double get overallAccuracy {
    if (unitQuizScores.isEmpty) return 0.0;
    final total = unitQuizScores.values.fold<int>(0, (sum, item) => sum + item);
    return total / unitQuizScores.length;
  }

  UserProgressModel copyWith({
    Set<String>? completedLessonIds,
    Map<String, int>? unitQuizScores,
    int? streakDays,
    int? totalXp,
    String? lastActiveDate,
  }) {
    return UserProgressModel(
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      unitQuizScores: unitQuizScores ?? this.unitQuizScores,
      streakDays: streakDays ?? this.streakDays,
      totalXp: totalXp ?? this.totalXp,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  Map<String, dynamic> toMap() => {
        'completedLessonIds': completedLessonIds.toList(),
        'unitQuizScores': unitQuizScores,
        'streakDays': streakDays,
        'totalXp': totalXp,
        'lastActiveDate': lastActiveDate,
      };

  factory UserProgressModel.fromMap(Map<String, dynamic> map) {
    final lessons = (map['completedLessonIds'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toSet();
    final rawScores = map['unitQuizScores'] as Map<String, dynamic>? ?? {};
    final scores = rawScores.map((k, v) => MapEntry(k, (v as num).toInt()));

    return UserProgressModel(
      completedLessonIds: lessons,
      unitQuizScores: scores,
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 1,
      totalXp: (map['totalXp'] as num?)?.toInt() ?? 0,
      lastActiveDate: map['lastActiveDate'] as String? ??
          DateTime.now().toIso8601String().substring(0, 10),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserProgressModel.fromJson(String source) =>
      UserProgressModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
