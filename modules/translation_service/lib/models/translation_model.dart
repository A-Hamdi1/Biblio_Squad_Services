class Translation {
  final String? recognizedText;
  final String? translatedText;
  final String? targetLanguage;

  Translation({
    this.recognizedText,
    this.translatedText,
    this.targetLanguage,
  });

  Map<String, dynamic> toMap() {
    return {
      'recognizedText': recognizedText,
      'translatedText': translatedText,
      'targetLanguage': targetLanguage,
    };
  }

  factory Translation.fromMap(Map<String, dynamic> map) {
    return Translation(
      recognizedText: map['recognizedText'],
      translatedText: map['translatedText'],
      targetLanguage: map['targetLanguage'],
    );
  }
}
