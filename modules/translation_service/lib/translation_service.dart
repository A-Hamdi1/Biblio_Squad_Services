library translation_service;

// Export models et screens
export 'ui/screens/settings_screen.dart';
export 'core/providers/language_provider.dart';

// Main service
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'core/providers/translation_providers.dart';
import 'ui/screens/translation_screen.dart';

/// TranslationService est le point d'entrée principal pour utiliser le module de traduction.
class TranslationService {
  static void initializeService() async {
    // Initialisation du service si nécessaire
  }

  /// Naviguer vers l'écran principal de traduction depuis n'importe quel contexte
  static void navigateToTranslationScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: TranslationProviders.providers,
          child: const TranslationScreen(),
        ),
      ),
    );
  }

  /// Obtenir les providers nécessaires pour ce module
  static List<SingleChildWidget> getProviders() {
    return TranslationProviders.providers;
  }
}