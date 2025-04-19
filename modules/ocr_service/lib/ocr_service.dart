
library ocr_service;

// Export models
export 'models/document_model.dart';

// Export screens
export 'ui/screens/image_picker_screen.dart';
export 'ui/screens/text_recognition_screen.dart';
export 'ui/screens/pdf_export_screen.dart';

// Main service
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocr_service/ui/screens/image_picker_screen.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'core/providers/document_provider.dart';
import 'core/providers/pdf_provider.dart';
import 'ui/screens/home_screen.dart';
import 'utils/pdf_utils.dart';
import 'utils/file_utils.dart';
import 'dart:io';

class OcrService {
  static void initializeService() async {
    WidgetsFlutterBinding.ensureInitialized();
  }

  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider(create: (_) => DocumentProvider()),
      ChangeNotifierProvider(create: (_) => PdfProvider()),
    ];
  }

  static void navigateToHomeScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: getProviders(),
          child: const HomeScreen(),
        ),
      ),
    );
  }

  static void navigateToCameraScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: getProviders(),
          child: const ImagePickerScreen(source: "camera"),
        ),
      ),
    );
  }

  static void navigateToGalleryScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: getProviders(),
          child: const ImagePickerScreen(source: "gallery"),
        ),
      ),
    );
  }

  static Future<String> processImage(BuildContext context, File imageFile) async {
    final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
    await documentProvider.processImage(imageFile);
    return documentProvider.currentDocument?.extractedText ?? '';
  }

  static Future<bool> copyTextToClipboard(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Texte copié!'),
          duration: Duration(milliseconds: 800),
          backgroundColor: Colors.green,
        ),
      );

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la copie: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  static Future<String> exportTextToPdf(BuildContext context, String text) async {
    final pdfProvider = Provider.of<PdfProvider>(context, listen: false);
    await pdfProvider.savePdf(text);

    if (pdfProvider.errorMessage.isNotEmpty) {
      throw Exception(pdfProvider.errorMessage);
    }

    return pdfProvider.savedFilePath;
  }
}