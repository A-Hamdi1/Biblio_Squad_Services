import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../../apis/recognition_api.dart';
import '../../apis/translation_api.dart';
import '../../models/translation_model.dart';

class TranslationProvider extends ChangeNotifier {
  CameraController? _cameraController;
  bool _isProcessing = false;
  Translation? _currentTranslation;
  String? _errorMessage;
  TranslateLanguage _selectedLanguage = TranslateLanguage.english;

  CameraController? get cameraController => _cameraController;
  bool get isProcessing => _isProcessing;
  Translation? get currentTranslation => _currentTranslation;
  String? get errorMessage => _errorMessage;
  TranslateLanguage get selectedLanguage => _selectedLanguage;

  TranslationProvider() {
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _errorMessage = 'No cameras available';
        notifyListeners();
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.max,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error initializing camera: ${e.toString()}';
      notifyListeners();
    }
  }

  void setSelectedLanguage(TranslateLanguage language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  Future<void> translateText() async {
    if (_cameraController == null || _isProcessing) return;

    _isProcessing = true;
    _currentTranslation = null;
    _errorMessage = null;
    notifyListeners();

    try {
      // Prendre une nouvelle photo
      final image = await _cameraController!.takePicture();
      final recognizedText = await RecognitionApi.recognizeText(
        InputImage.fromFile(File(image.path)),
      );

      if (recognizedText == null || recognizedText.isEmpty) {
        _errorMessage = 'No text recognized';
        _isProcessing = false;
        notifyListeners();
        return;
      }

      final translatedText = await TranslationApi.translateText(
        recognizedText,
        _selectedLanguage,
      );

      if (translatedText == null) {
        _errorMessage = 'Translation failed';
        _isProcessing = false;
        notifyListeners();
        return;
      }

      _currentTranslation = Translation(
        recognizedText: recognizedText,
        translatedText: translatedText,
        targetLanguage: _selectedLanguage.name,
      );
      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error recognizing or translating text: ${e.toString()}';
      _isProcessing = false;
      notifyListeners();
    }
  }

  void reset() {
    _currentTranslation = null;
    _errorMessage = null;
    _isProcessing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
