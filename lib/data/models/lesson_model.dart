import 'card_model.dart';
import 'story_model.dart';

class LessonModel {
  final String id;
  final String unitId;
  final String title;
  final int order;
  final String introduction;
  final List<CardModel> cards;
  final StoryModel? story;
  final String? tracingTarget;

  const LessonModel({
    required this.id,
    required this.unitId,
    required this.title,
    required this.order,
    required this.introduction,
    required this.cards,
    this.story,
    this.tracingTarget,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    final rawCards = json['cards'] as List<dynamic>? ?? [];
    return LessonModel(
      id: json['id'] as String? ?? '',
      unitId: json['unitId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      order: json['order'] as int? ?? 1,
      introduction: json['introduction'] as String? ?? '',
      cards: rawCards
          .map((item) => CardModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      story: json['story'] != null
          ? StoryModel.fromJson(json['story'] as Map<String, dynamic>)
          : null,
      tracingTarget: json['tracingTarget'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'unitId': unitId,
        'title': title,
        'order': order,
        'introduction': introduction,
        'cards': cards.map((c) => c.toJson()).toList(),
        'story': story?.toJson(),
        'tracingTarget': tracingTarget,
      };
}
