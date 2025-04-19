class Document {
  final String imagePath;
  final String extractedText;
  final DateTime date;
  final String title;

  Document({
    required this.imagePath,
    required this.extractedText,
    required this.date,
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'extractedText': extractedText,
      'date': date.toIso8601String(),
      'title': title,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      imagePath: map['imagePath'],
      extractedText: map['extractedText'],
      date: DateTime.parse(map['date']),
      title: map['title'],
    );
  }
}