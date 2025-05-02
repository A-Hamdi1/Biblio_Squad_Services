import 'package:auth_service/core/providers/auth_provider.dart';
import 'package:barcode_service/barcode_service.dart';
import 'package:document_scan_service/document_scan_service.dart';
import 'package:flutter/material.dart';
import 'package:ocr_service/ocr_service.dart';
import 'package:translation_service/translation_service.dart';
import 'package:auth_service/auth_service.dart';
import 'package:provider/provider.dart';

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

/// Returns the list of vision features based on the user's role
Future<List<VisionFeaturesModel>> getVisionFeatures(
    BuildContext context) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final role = await authProvider.getRoleFromPrefs();

  // Common features available to both Author and Client
  final commonFeatures = [
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
        // Placeholder for future implementation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fonctionnalité en cours de développement.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      },
    ),
  ];

  if (role == 'Author') {
    return [
      ...commonFeatures,
      VisionFeaturesModel(
        image: "assets/images/scan_document.png",
        title: "Document scanner",
        onPress: (context) {
          DocumentScanService.navigateToHomeScreen(context);
        },
      ),
    ];
  } else if (role == 'Admin') {
    return [
      ...commonFeatures,
      VisionFeaturesModel(
        image: "assets/images/face_recognition.png",
        title: "Gestion Users",
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
    ];
  } else {
    return commonFeatures;
  }
}
