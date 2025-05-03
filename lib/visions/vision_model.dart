import 'package:barcode_service/barcode_service.dart';
import 'package:document_scan_service/document_scan_service.dart';
import 'package:flutter/material.dart';
import 'package:ocr_service/ocr_service.dart';
import 'package:translation_service/translation_service.dart';
import 'package:gestion_users_service/gestion_users_service.dart';

class VisionFeaturesModel {
  final String title;
  final String image;
  final Function(BuildContext context) onPress;

  VisionFeaturesModel({
    required this.image,
    required this.title,
    required this.onPress,
  });
}

Future<List<VisionFeaturesModel>> getVisionFeatures(
    BuildContext context) async {
  // Toutes les fonctionnalités sont accessibles à tous
  return [
    VisionFeaturesModel(
      image: "assets/images/ocr.png",
      title: "Text Recognition",
      onPress: (context) {
        OcrService.navigateToHomeScreen(context);
      },
    ),
    VisionFeaturesModel(
      image: "assets/images/translate.png",
      title: "Translate",
      onPress: (context) {
        TranslationService.navigateToTranslationScreen(context);
      },
    ),
    VisionFeaturesModel(
      image: "assets/images/barcode.png",
      title: "Barcode",
      onPress: (context) {
        BarcodeService.navigateToBarcodeScanScreen(context);
      },
    ),
    VisionFeaturesModel(
      image: "assets/images/faq-chat.png",
      title: "FAQ Chat",
      onPress: (context) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fonctionnalité en cours de développement.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      },
    ),
    VisionFeaturesModel(
      image: "assets/images/scan_document.png",
      title: "Document scanner",
      onPress: (context) {
        DocumentScanService.navigateToHomeScreen(context);
      },
    ),
    VisionFeaturesModel(
      image: "assets/images/gestion_users.png",
      title: "Gestion Users",
      onPress: (context) {
        GestionUsersService.navigateToUsersListScreen(context);
      },
    ),
  ];
}
