import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../../apis/recognition_api.dart';
import '../../apis/translation_api.dart';
import '../../models/translation_model.dart';

enum TranslationStatus { initializing, ready, processing, completed, error }

class TranslationProvider extends ChangeNotifier {
  CameraController? _cameraController;
  TranslationStatus _status = TranslationStatus.initializing;
  Translation? _currentTranslation;
  String? _errorMessage;
  TranslateLanguage _selectedLanguage = TranslateLanguage.english;

  CameraController? get cameraController => _cameraController;
  TranslationStatus get status => _status;
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
        _status = TranslationStatus.error;
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
      _status = TranslationStatus.ready;
      notifyListeners();
    } catch (e) {
      _status = TranslationStatus.error;
      _errorMessage = 'Error initializing camera: ${e.toString()}';
      notifyListeners();
    }
  }

  void setSelectedLanguage(TranslateLanguage language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  Future<void> translateText() async {
    if (_cameraController == null || _status == TranslationStatus.processing)
      return;

    _status = TranslationStatus.processing;
    _currentTranslation = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final image = await _cameraController!.takePicture();
      final recognizedText = await RecognitionApi.recognizeText(
        InputImage.fromFile(File(image.path)),
      );

      if (recognizedText == null || recognizedText.isEmpty) {
        _status = TranslationStatus.error;
        _errorMessage = 'No text recognized';
        notifyListeners();
        return;
      }

      final translatedText = await TranslationApi.translateText(
        recognizedText,
        _selectedLanguage,
      );

      if (translatedText == null) {
        _status = TranslationStatus.error;
        _errorMessage = 'Translation failed';
        notifyListeners();
        return;
      }

      _currentTranslation = Translation(
        recognizedText: recognizedText,
        translatedText: translatedText,
        targetLanguage: _selectedLanguage.name,
      );
      _status = TranslationStatus.completed;
      notifyListeners();

      // Réinitialiser pour permettre une nouvelle traduction
      _status = TranslationStatus.ready;
      notifyListeners();
    } catch (e) {
      _status = TranslationStatus.error;
      _errorMessage = 'Error recognizing or translating text';
      notifyListeners();

      // Réinitialiser pour permettre une nouvelle tentative
      _status = TranslationStatus.ready;
      notifyListeners();
    }
  }

  void reset() {
    _currentTranslation = null;
    _errorMessage = null;
    _status = TranslationStatus.ready;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
