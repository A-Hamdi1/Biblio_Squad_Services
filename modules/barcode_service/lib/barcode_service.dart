library barcode_service;

// Export models
export 'models/book_model.dart';

// Export screens
export 'ui/screens/barcode_scan_screen.dart';
export 'ui/widgets/author_books_page.dart';
import 'data/book_data.dart';
import 'ui/screens/barcode_scan_screen.dart';

// Main service
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'core/providers/barcode_providers.dart';

/// BarcodeService is the main entry point for using the barcode scanning module.
class BarcodeService {
  static void initializeService() async {
    // Run the function to add books only once when the service starts
     addMultipleBooks();
  }
  /// Navigate to the barcode scanning screen from any context
  static void navigateToBarcodeScanScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: BarcodeProviders.providers,
          child: const BarcodeScanScreen(),
        ),
      ),
    );
  }

  /// Get the providers required for this module
  static List<SingleChildWidget> getProviders() {
    return BarcodeProviders.providers;
  }
}