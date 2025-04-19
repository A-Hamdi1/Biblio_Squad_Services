import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../../models/document_model.dart';

class DocumentProvider extends ChangeNotifier {
  Document? _currentDocument;
  bool _isProcessing = false;
  String _errorMessage = '';

  Document? get currentDocument => _currentDocument;
  bool get isProcessing => _isProcessing;
  String get errorMessage => _errorMessage;

  Future<void> processImage(File imageFile) async {
    _isProcessing = true;
    _errorMessage = '';
    notifyListeners();

    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      String extractedText = recognizedText.text;

      if (extractedText.isEmpty) {
        extractedText = "No text found";
      }

      _currentDocument = Document(
        imagePath: imageFile.path,
        extractedText: extractedText,
        date: DateTime.now(),
        title: 'Document ${DateTime.now().toIso8601String()}',
      );
    } catch (e) {
      _errorMessage = "Error: Failed to recognize text";
    } finally {
      textRecognizer.close();
      _isProcessing = false;
      notifyListeners();
    }
  }

  void clearCurrentDocument() {
    _currentDocument = null;
    notifyListeners();
  }
}