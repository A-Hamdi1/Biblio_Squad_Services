import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:provider/provider.dart';
import '../services/translation_services.dart';
import 'language_provider.dart';

enum TranslationStatus { initializing, ready, processing, error }

class TranslationProvider extends ChangeNotifier {
  final TranslationServices _translationService;
  CameraController? _cameraController;
  TranslationStatus _status = TranslationStatus.initializing;
  Map<String, String> _detectedTexts = {};
  String? _errorMessage;
  String _currentTargetLanguage = '';

  CameraController? get cameraController => _cameraController;
  TranslationStatus get status => _status;
  Map<String, String> get detectedTexts => _detectedTexts;
  String? get errorMessage => _errorMessage;

  TranslationProvider(this._translationService) {
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final permissionGranted = await _translationService.requestCameraPermission();
      if (!permissionGranted) {
        _status = TranslationStatus.error;
        _errorMessage = 'Camera permission not granted';
        notifyListeners();
        return;
      }

      final cameras = await _translationService.getAvailableCameras();
      if (cameras.isEmpty) {
        _status = TranslationStatus.error;
        _errorMessage = 'No cameras available';
        notifyListeners();
        return;
      }

      _cameraController = await _translationService.initializeCamera(cameras.first);
      _status = TranslationStatus.ready;
      notifyListeners();
    } catch (e) {
      _status = TranslationStatus.error;
      _errorMessage = 'Error initializing camera: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> captureAndTranslate(BuildContext context) async {
    if (_status == TranslationStatus.processing || _cameraController == null) return;

    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final targetLanguage = languageProvider.targetLanguage;

    bool languageChanged = _currentTargetLanguage != targetLanguage;
    _currentTargetLanguage = targetLanguage;

    if (_detectedTexts.isNotEmpty && !languageChanged) {
      _detectedTexts = {};
      notifyListeners();
      return;
    }

    _status = TranslationStatus.processing;
    notifyListeners();

    try {
      final sourceLanguage = languageProvider.isAutomaticDetection ? 'auto' : languageProvider.sourceLanguage;

      final imageFile = await _cameraController!.takePicture();
      final recognizedText = await _translationService.processImage(imageFile);

      if (recognizedText.text.isNotEmpty) {
        final Map<String, String> newDetectedTexts = {};

        for (final TextBlock block in recognizedText.blocks) {
          for (final TextLine line in block.lines) {
            if (line.text.isNotEmpty) {
              final translation = await _translationService.translateText(
                line.text,
                sourceLanguage,
                targetLanguage,
              );

              newDetectedTexts[line.text] = translation;
            }
          }
        }

        _detectedTexts = newDetectedTexts;
      }

      _status = TranslationStatus.ready;
    } catch (e) {
      _status = TranslationStatus.error;
      _errorMessage = 'Error processing image: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  bool checkLanguageChange(String currentTargetLanguage) {
    bool changed = false;

    if (_currentTargetLanguage != '' && _currentTargetLanguage != currentTargetLanguage) {
      _detectedTexts = {};
      _currentTargetLanguage = currentTargetLanguage;
      changed = true;
    } else if (_currentTargetLanguage == '') {
      _currentTargetLanguage = currentTargetLanguage;
    }

    return changed;
  }

  void applyLanguageChange(String currentTargetLanguage) {
    if (checkLanguageChange(currentTargetLanguage)) {
      notifyListeners();
    }
  }

  void reset() {
    _detectedTexts = {};
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
