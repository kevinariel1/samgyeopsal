import 'dart:convert';
import 'quiz_attempt_model.dart';
import 'unit_model.dart';

class UserProgressModel {
  final Set<String> completedLessonIds;
  final Map<String, int> unitQuizScores; // unitId -> score percentage
  final Map<String, QuizAttemptModel> lastQuizAttempts; // unitId -> last attempt
  final Map<String, int> quizHighestXp; // quizId or unitId -> highest EXP earned
  final Set<String> unlockedBadges;
  final int streakDays;
  final int longestStreak;
  final List<String> activeDates; // ISO-8601 YYYY-MM-DD
  final int totalXp;
  final String lastActiveDate;

  const UserProgressModel({
    required this.completedLessonIds,
    required this.unitQuizScores,
    this.lastQuizAttempts = const {},
    this.quizHighestXp = const {},
    this.unlockedBadges = const {},
    this.streakDays = 1,
    this.longestStreak = 1,
    this.activeDates = const [],
    this.totalXp = 0,
    required this.lastActiveDate,
  });

  factory UserProgressModel.initial() {
    final today = DateTime.now().toLocal().toIso8601String().substring(0, 10);
    return UserProgressModel(
      completedLessonIds: {},
      unitQuizScores: {},
      lastQuizAttempts: {},
      quizHighestXp: {},
      unlockedBadges: {},
      streakDays: 1,
      longestStreak: 1,
      activeDates: [today],
      totalXp: 0,
      lastActiveDate: today,
    );
  }

  bool isLessonCompleted(String lessonId) {
    return completedLessonIds.contains(lessonId);
  }

  bool hasBadge(String badgeId) {
    return unlockedBadges.contains(badgeId);
  }

  bool isUnitPassed(String unitId, [int passingScore = 80]) {
    final score = unitQuizScores[unitId];
    return score != null && score >= passingScore;
  }

  QuizAttemptModel? getLastAttempt(String unitId) {
    return lastQuizAttempts[unitId];
  }

  int getQuizHighestXp(String quizOrUnitId) {
    return quizHighestXp[quizOrUnitId] ?? 0;
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
    Map<String, QuizAttemptModel>? lastQuizAttempts,
    Map<String, int>? quizHighestXp,
    Set<String>? unlockedBadges,
    int? streakDays,
    int? longestStreak,
    List<String>? activeDates,
    int? totalXp,
    String? lastActiveDate,
  }) {
    return UserProgressModel(
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      unitQuizScores: unitQuizScores ?? this.unitQuizScores,
      lastQuizAttempts: lastQuizAttempts ?? this.lastQuizAttempts,
      quizHighestXp: quizHighestXp ?? this.quizHighestXp,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      streakDays: streakDays ?? this.streakDays,
      longestStreak: longestStreak ?? this.longestStreak,
      activeDates: activeDates ?? this.activeDates,
      totalXp: totalXp ?? this.totalXp,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  Map<String, dynamic> toMap() => {
        'completedLessonIds': completedLessonIds.toList(),
        'unitQuizScores': unitQuizScores,
        'lastQuizAttempts': lastQuizAttempts.map((k, v) => MapEntry(k, v.toMap())),
        'quizHighestXp': quizHighestXp,
        'unlockedBadges': unlockedBadges.toList(),
        'streakDays': streakDays,
        'longestStreak': longestStreak,
        'activeDates': activeDates,
        'totalXp': totalXp,
        'lastActiveDate': lastActiveDate,
      };

  factory UserProgressModel.fromMap(Map<String, dynamic> map) {
    final lessons = (map['completedLessonIds'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toSet();
    final rawScores = map['unitQuizScores'] as Map<String, dynamic>? ?? {};
    final scores = rawScores.map((k, v) => MapEntry(k, (v as num).toInt()));

    final rawAttempts = map['lastQuizAttempts'] as Map<String, dynamic>? ?? {};
    final attempts = rawAttempts.map((k, v) {
      if (v is Map<String, dynamic>) {
        return MapEntry(k, QuizAttemptModel.fromMap(v));
      }
      return MapEntry(k, QuizAttemptModel.fromMap(Map<String, dynamic>.from(v as Map)));
    });

    final rawQuizXp = map['quizHighestXp'] as Map<String, dynamic>? ?? {};
    final quizXp = rawQuizXp.map((k, v) => MapEntry(k, (v as num).toInt()));

    final badges = (map['unlockedBadges'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toSet();
    final rawDates = (map['activeDates'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final lastDate = map['lastActiveDate'] as String? ??
        DateTime.now().toLocal().toIso8601String().substring(0, 10);
    final activeDatesList = rawDates.isEmpty ? [lastDate] : rawDates;
    final currentStreak = (map['streakDays'] as num?)?.toInt() ?? 1;

    return UserProgressModel(
      completedLessonIds: lessons,
      unitQuizScores: scores,
      lastQuizAttempts: attempts,
      quizHighestXp: quizXp,
      unlockedBadges: badges,
      streakDays: currentStreak,
      longestStreak: (map['longestStreak'] as num?)?.toInt() ?? currentStreak,
      activeDates: activeDatesList,
      totalXp: (map['totalXp'] as num?)?.toInt() ?? 0,
      lastActiveDate: lastDate,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserProgressModel.fromJson(String source) =>
      UserProgressModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
  /// Returns calendar activity data for a window of days up to today.
  List<CalendarDayStatus> getStreakCalendar({int daysBack = 14}) {
    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final activeSet = activeDates.toSet();

    return List.generate(daysBack, (i) {
      final d = today.subtract(Duration(days: (daysBack - 1) - i));
      final dateStr = d.toIso8601String().substring(0, 10);
      final hasActivity = activeSet.contains(dateStr);
      final isToday = d.year == today.year && d.month == today.month && d.day == today.day;
      return CalendarDayStatus(
        date: d,
        dateString: dateStr,
        hasActivity: hasActivity,
        isToday: isToday,
      );
    });
  }
}

class CalendarDayStatus {
  final DateTime date;
  final String dateString;
  final bool hasActivity;
  final bool isToday;

  const CalendarDayStatus({
    required this.date,
    required this.dateString,
    required this.hasActivity,
    required this.isToday,
  });

}
