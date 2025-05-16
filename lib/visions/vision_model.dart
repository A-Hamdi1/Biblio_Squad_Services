import 'package:auth_service/auth_service.dart';
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
  final bool Function(UserModel? user) hasAccess;

  VisionFeaturesModel({
    required this.image,
    required this.title,
    required this.onPress,
    required this.hasAccess,
  });
}

Future<List<VisionFeaturesModel>> getVisionFeatures(
    BuildContext context) async {
  return [
    VisionFeaturesModel(
      image: "assets/images/ocr.png",
      title: "Text Recognition",
      onPress: (context) {
        final user = AuthService.getCurrentUser(context);
        if (user != null && user.canAccessOcrService()) {
          OcrService.navigateToHomeScreen(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Vous n'avez pas accès à cette fonctionnalité."),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      hasAccess: (user) {
        return user != null && user.canAccessOcrService();
      },
    ),
    VisionFeaturesModel(
      image: "assets/images/translate.png",
      title: "Translate",
      onPress: (context) {
        final user = AuthService.getCurrentUser(context);
        if (user != null && user.canAccessTranslationService()) {
          TranslationService.navigateToTranslationScreen(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Vous n'avez pas accès à cette fonctionnalité."),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      hasAccess: (user) {
        return user != null && user.canAccessTranslationService();
      },
    ),
    VisionFeaturesModel(
      image: "assets/images/barcode.png",
      title: "Barcode",
      onPress: (context) {
        final user = AuthService.getCurrentUser(context);
        if (user != null && user.canAccessBarcodeService()) {
          BarcodeService.navigateToBarcodeScanScreen(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Vous n'avez pas accès à cette fonctionnalité."),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      hasAccess: (user) {
        return user != null && user.canAccessBarcodeService();
      },
    ),
    VisionFeaturesModel(
      image: "assets/images/faq-chat.png",
      title: "FAQ Chat",
      onPress: (context) {
        final user = AuthService.getCurrentUser(context);
        if (user != null && user.canAccessSmartReplyService()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fonctionnalité en cours de développement.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Vous n'avez pas accès à cette fonctionnalité."),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      hasAccess: (user) {
        return user != null && user.canAccessSmartReplyService();
      },
    ),
    VisionFeaturesModel(
      image: "assets/images/scan_document.png",
      title: "Document scanner",
      onPress: (context) {
        final user = AuthService.getCurrentUser(context);
        if (user != null && user.canAccessDocumentScanService()) {
          DocumentScanService.navigateToHomeScreen(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Vous n'avez pas accès à cette fonctionnalité."),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      hasAccess: (user) {
        return user != null && user.canAccessDocumentScanService();
      },
    ),
    VisionFeaturesModel(
      image: "assets/images/gestion_users.png",
      title: "Gestion Users",
      onPress: (context) {
        final user = AuthService.getCurrentUser(context);
        if (user != null && user.canAccessGestionUsersService()) {
          GestionUsersService.navigateToUsersListScreen(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Vous n'avez pas accès à cette fonctionnalité."),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      hasAccess: (user) {
        return user != null && user.canAccessGestionUsersService();
      },
    ),
  ];
}
