library document_scan_service;

// Export models
export 'models/document_scan_model.dart';

// Export screens
export 'ui/screens/home_screen.dart';
export 'ui/screens/detail_document_screen.dart';
export 'ui/screens/edit_document_screen.dart';
export 'ui/screens/save_document_screen.dart';
export 'ui/screens/document_category_screen.dart';
export 'ui/screens/latest_documents_screen.dart';

// Export providers
export 'core/providers/document_provider.dart';

// Export data
export 'data/document_local_datasource.dart';

// Export widgets
export 'ui/widgets/menu_categories.dart';
export 'ui/widgets/category_button.dart';

import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'core/providers/document_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/document_category_screen.dart';
import 'ui/screens/save_document_screen.dart';
import 'ui/screens/detail_document_screen.dart';
import 'ui/screens/edit_document_screen.dart';
import 'models/document_scan_model.dart';

class DocumentScanService {
  static void initializeService() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider(create: (_) => DocumentsProvider()),
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

  static void navigateToCategoryScreen(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: getProviders(),
          child: DocumentCategoryPage(categoryTitle: category),
        ),
      ),
    );
  }

  static Future<void> scanDocument(BuildContext context) async {
    try {
      final documentOptions = DocumentScannerOptions(
        documentFormat: DocumentFormat.jpeg,
        mode: ScannerMode.filter,
        pageLimit: 100,
        isGalleryImport: true,
      );

      final documentScanner = DocumentScanner(options: documentOptions);
      final DocumentScanningResult result =
          await documentScanner.scanDocument();
      final images = result.images;

      if (images.isNotEmpty && context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MultiProvider(
              providers: getProviders(),
              child: SaveDocumentPage(pathImage: images),
            ),
          ),
        );
        Provider.of<DocumentsProvider>(context, listen: false).loadDocuments();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<String> extractTextFromImages(
      BuildContext context, List<String> imagePaths) async {
    if (imagePaths.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No images to extract text from')),
        );
      }
      return '';
    }

    String extractedText = '';
    try {
      for (String imagePath in imagePaths) {
        final inputImage = InputImage.fromFilePath(imagePath);
        final textRecognizer = TextRecognizer();
        final RecognizedText recognizedText =
            await textRecognizer.processImage(inputImage);
        extractedText += '${recognizedText.text}\n';
        textRecognizer.close();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error extracting text: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return extractedText;
  }

  static Future<bool> saveDocument(
      BuildContext context, DocumentModel document) async {
    final documentProvider =
        Provider.of<DocumentsProvider>(context, listen: false);
    final success = await documentProvider.saveDocument(document);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save document: ${documentProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return success;
  }

  static Future<bool> deleteDocument(
      BuildContext context, int documentId) async {
    final documentProvider =
        Provider.of<DocumentsProvider>(context, listen: false);
    final success = await documentProvider.deleteDocument(documentId);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete document: ${documentProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return success;
  }

  static Future<bool> requestStoragePermission(BuildContext context) async {
    final status = await Permission.storage.request();
    if (!status.isGranted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission denied'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return status.isGranted;
  }

  static void navigateToDetailScreen(
      BuildContext context, DocumentModel document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: getProviders(),
          child: DetailDocumentPage(document: document),
        ),
      ),
    );
  }

  static void navigateToEditScreen(
      BuildContext context, DocumentModel document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: getProviders(),
          child: EditDocumentPage(document: document),
        ),
      ),
    );
  }
}
