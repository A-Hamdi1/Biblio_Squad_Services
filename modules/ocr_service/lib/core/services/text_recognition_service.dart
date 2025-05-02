import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../models/document_model.dart';

class TextRecognitionService {
  final TextRecognizer _textRecognizer;

  // Singleton pattern
  static final TextRecognitionService _instance =
      TextRecognitionService._internal();

  factory TextRecognitionService() => _instance;

  TextRecognitionService._internal()
      : _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// Process an image file and extract text using ML Kit
  Future<Document> processImage(File imageFile, {String? title}) async {
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      String extractedText = recognizedText.text;

      if (extractedText.isEmpty) {
        extractedText = "No text found";
      }

      return Document(
        imagePath: imageFile.path,
        extractedText: extractedText,
        date: DateTime.now(),
        title: title ?? 'Document ${DateTime.now().toIso8601String()}',
      );
    } catch (e) {
      throw Exception("Failed to recognize text: $e");
    }
  }

  /// Close the text recognizer when not needed anymore
  void dispose() {
    _textRecognizer.close();
  }
}
