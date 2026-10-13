class StoryPageModel {
  final String text;
  final String koreanHighlight;
  final String sound;
  final String icon;

  const StoryPageModel({
    required this.text,
    required this.koreanHighlight,
    required this.sound,
    required this.icon,
  });

  factory StoryPageModel.fromJson(Map<String, dynamic> json) {
    return StoryPageModel(
      text: json['text'] as String? ?? '',
      koreanHighlight: json['koreanHighlight'] as String? ?? '',
      sound: json['sound'] as String? ?? '',
      icon: json['icon'] as String? ?? 'auto_stories',
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'koreanHighlight': koreanHighlight,
        'sound': sound,
        'icon': icon,
      };
}

class StoryModel {
  final String title;
  final List<StoryPageModel> storyPages;

  const StoryModel({
    required this.title,
    required this.storyPages,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    final list = json['storyPages'] as List<dynamic>? ?? [];
    return StoryModel(
      title: json['title'] as String? ?? '',
      storyPages: list
          .map((item) => StoryPageModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'storyPages': storyPages.map((e) => e.toJson()).toList(),
      };
}
