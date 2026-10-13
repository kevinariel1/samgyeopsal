enum QuestionType {
  multipleChoice,
  listening,
  matching,
  tracing;

  static QuestionType fromString(String val) {
    switch (val) {
      case 'listening':
        return QuestionType.listening;
      case 'matching':
        return QuestionType.matching;
      case 'tracing':
        return QuestionType.tracing;
      case 'multiple_choice':
      default:
        return QuestionType.multipleChoice;
    }
  }

  String toStr() {
    switch (this) {
      case QuestionType.listening:
        return 'listening';
      case QuestionType.matching:
        return 'matching';
      case QuestionType.tracing:
        return 'tracing';
      case QuestionType.multipleChoice:
        return 'multiple_choice';
    }
  }
}

class QuizQuestionModel {
  final String id;
  final QuestionType type;
  final String prompt;
  final String soundToPlay;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestionModel({
    required this.id,
    required this.type,
    required this.prompt,
    required this.soundToPlay,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    return QuizQuestionModel(
      id: json['id'] as String? ?? '',
      type: QuestionType.fromString(json['type'] as String? ?? ''),
      prompt: json['prompt'] as String? ?? '',
      soundToPlay: json['soundToPlay'] as String? ?? '',
      options: rawOptions.map((e) => e.toString()).toList(),
      correctIndex: json['correctIndex'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toStr(),
        'prompt': prompt,
        'soundToPlay': soundToPlay,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}

class QuizModel {
  final String id;
  final String unitId;
  final int passingScorePercent;
  final List<QuizQuestionModel> questions;

  const QuizModel({
    required this.id,
    required this.unitId,
    this.passingScorePercent = 80,
    required this.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final list = json['questions'] as List<dynamic>? ?? [];
    return QuizModel(
      id: json['id'] as String? ?? '',
      unitId: json['unitId'] as String? ?? '',
      passingScorePercent: json['passingScorePercent'] as int? ?? 80,
      questions: list
          .map((item) => QuizQuestionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'unitId': unitId,
        'passingScorePercent': passingScorePercent,
        'questions': questions.map((e) => e.toJson()).toList(),
      };
}
