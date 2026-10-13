import 'lesson_model.dart';
import 'quiz_model.dart';

class UnitModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final int order;
  final int unlockRequirement;
  final List<LessonModel> lessons;
  final QuizModel? quiz;

  const UnitModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.order,
    this.unlockRequirement = 0,
    required this.lessons,
    this.quiz,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessons'] as List<dynamic>? ?? [];
    return UnitModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      order: json['order'] as int? ?? 1,
      unlockRequirement: json['unlockRequirement'] as int? ?? 0,
      lessons: rawLessons
          .map((item) => LessonModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      quiz: json['quiz'] != null
          ? QuizModel.fromJson(json['quiz'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'order': order,
        'unlockRequirement': unlockRequirement,
        'lessons': lessons.map((l) => l.toJson()).toList(),
        'quiz': quiz?.toJson(),
      };
}
