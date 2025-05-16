import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/document_model.dart';
import '../services/text_recognition_service.dart';
import '../services/file_export_service.dart';

class DocumentProvider extends ChangeNotifier {
  final TextRecognitionService _recognitionService = TextRecognitionService();
  final FileExportService _exportService = FileExportService();

  Document? _currentDocument;
  bool _isProcessing = false;
  String _errorMessage = '';

  Document? get currentDocument => _currentDocument;
  bool get isProcessing => _isProcessing;
  String get errorMessage => _errorMessage;

  Future<void> processImage(File imageFile, {String? title}) async {
    _isProcessing = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _currentDocument =
          await _recognitionService.processImage(imageFile, title: title);
    } catch (e) {
      _errorMessage = "Error: Failed to recognize text";
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<String?> saveTextToFile(
      {ExportFormat format = ExportFormat.text}) async {
    if (_currentDocument == null) {
      _errorMessage = "No document to save";
      notifyListeners();
      return null;
    }

    try {
      final filename = "document_${DateTime.now().millisecondsSinceEpoch}";
      final filePath = await _exportService.saveTextToFile(
        _currentDocument!.extractedText,
        filename: filename,
        format: format,
      );
      return filePath;
    } catch (e) {
      _errorMessage = "Error: Failed to save file";
      notifyListeners();
      return null;
    }
  }

  Future<void> shareText({String? subject}) async {
    if (_currentDocument == null) {
      _errorMessage = "No document to share";
      notifyListeners();
      return;
    }

    try {
      await _exportService.shareText(
        _currentDocument!.extractedText,
        subject: subject ?? _currentDocument!.title,
      );
    } catch (e) {
      _errorMessage = "Error: Failed to share text";
      notifyListeners();
    }
  }

  void clearCurrentDocument() {
    _currentDocument = null;
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _recognitionService.dispose();
    super.dispose();
  }
}
