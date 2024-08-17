// domain/entities/sound_to_text_class.dart
class SoundToTextClass {
  final String? text;

  SoundToTextClass({required this.text});

  factory SoundToTextClass.fromJson(Map<String, dynamic> json) {
    return SoundToTextClass(
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
}
