class CardModel {
  final String id;
  final String korean;
  final String romanization;
  final String meaning;
  final String sound;
  final String mnemonic;
  final String exampleWord;
  final String iconName;

  const CardModel({
    required this.id,
    required this.korean,
    required this.romanization,
    required this.meaning,
    required this.sound,
    required this.mnemonic,
    required this.exampleWord,
    required this.iconName,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as String? ?? '',
      korean: json['korean'] as String? ?? '',
      romanization: json['romanization'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      sound: json['sound'] as String? ?? '',
      mnemonic: json['mnemonic'] as String? ?? '',
      exampleWord: json['exampleWord'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'lightbulb',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'korean': korean,
        'romanization': romanization,
        'meaning': meaning,
        'sound': sound,
        'mnemonic': mnemonic,
        'exampleWord': exampleWord,
        'iconName': iconName,
      };
}
