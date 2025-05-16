library translation_service;

// Export models
export 'models/translation_model.dart';

// Export screens
export 'ui/screens/translation_screen.dart';

// Export APIs
export 'apis/recognition_api.dart';
export 'apis/translation_api.dart';

// Main service
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'core/providers/translation_provider.dart';
import 'ui/screens/translation_screen.dart';

class TranslationService {
  static void initializeService() async {
    WidgetsFlutterBinding.ensureInitialized();
  }

  /// Navigate to the translation screen from any context
  static void navigateToTranslationScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: getProviders(),
          child: const TranslationScreen(),
        ),
      ),
    );
  }

  /// Get the providers required for this module
  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider(create: (_) => TranslationProvider()),
    ];
  }
}
