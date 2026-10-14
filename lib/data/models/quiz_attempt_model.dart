class QuizAttemptModel {
  final String unitId;
  final String quizId;
  final int scorePercent;
  final String completedAt; // ISO-8601 string
  final List<String> questionIds; // IDs in the exact order presented
  final Map<String, int> selectedOptionIndices; // questionId -> selectedIndex

  const QuizAttemptModel({
    required this.unitId,
    required this.quizId,
    required this.scorePercent,
    required this.completedAt,
    required this.questionIds,
    required this.selectedOptionIndices,
  });

  Map<String, dynamic> toMap() => {
        'unitId': unitId,
        'quizId': quizId,
        'scorePercent': scorePercent,
        'completedAt': completedAt,
        'questionIds': questionIds,
        'selectedOptionIndices': selectedOptionIndices,
      };

  factory QuizAttemptModel.fromMap(Map<String, dynamic> map) {
    final rawQuestions = map['questionIds'] as List<dynamic>? ?? [];
    final rawAnswers = map['selectedOptionIndices'] as Map<String, dynamic>? ?? {};

    return QuizAttemptModel(
      unitId: map['unitId'] as String? ?? '',
      quizId: map['quizId'] as String? ?? '',
      scorePercent: (map['scorePercent'] as num?)?.toInt() ?? 0,
      completedAt: map['completedAt'] as String? ?? '',
      questionIds: rawQuestions.map((e) => e.toString()).toList(),
      selectedOptionIndices: rawAnswers.map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }
}
