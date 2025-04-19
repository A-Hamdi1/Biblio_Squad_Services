import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:translator/translator.dart';
import 'package:permission_handler/permission_handler.dart';

class TranslationServices {
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();
  final GoogleTranslator _translator = GoogleTranslator();

  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } catch (e) {
      return [];
    }
  }

  Future<CameraController> initializeCamera(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller.initialize();
    return controller;
  }

  Future<RecognizedText> processImage(XFile imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    return await _textRecognizer.processImage(inputImage);
  }

  Future<String> translateText(String text, String sourceLanguage, String targetLanguage) async {
    try {
      final translation = await _translator.translate(
        text,
        from: sourceLanguage,
        to: targetLanguage,
      );
      return translation.text;
    } catch (e) {
      debugPrint('Translation error: $e');
      return 'Translation error';
    }
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  void close() {
    _textRecognizer.close();
  }
}