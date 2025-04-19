import 'dart:io';
import 'package:flutter/material.dart';
import '../../utils/pdf_utils.dart';
import '../../utils/file_utils.dart';

class PdfProvider extends ChangeNotifier {
  bool _isSaving = false;
  String _savedFilePath = '';
  String _errorMessage = '';

  bool get isSaving => _isSaving;
  String get savedFilePath => _savedFilePath;
  String get errorMessage => _errorMessage;

  Future<void> savePdf(String text) async {
    _isSaving = true;
    _errorMessage = '';
    _savedFilePath = '';
    notifyListeners();

    try {
      final pdfUtils = PdfUtils();
      final pdfBytes = await pdfUtils.generatePdf(text);
      String filePath = await FileUtils.getFilePath();
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      _savedFilePath = filePath;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void reset() {
    _savedFilePath = '';
    _errorMessage = '';
    notifyListeners();
  }
}