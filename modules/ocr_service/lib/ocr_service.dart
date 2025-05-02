library ocr_service;

// === EXPORTS ===

// Export models
export 'models/document_model.dart';

// Export core
export 'core/constants/app_colors.dart';
export 'core/constants/app_strings.dart';
export 'core/constants/app_theme.dart';
export 'core/providers/document_provider.dart';
export 'core/services/text_recognition_service.dart';
export 'core/services/file_export_service.dart';
export 'core/utils/file_utils.dart';

// Export UI components
export 'ui/components/app_button.dart';
export 'ui/components/app_header.dart';
export 'ui/components/app_text_field.dart';

// Export screens
export 'ui/screens/home_screen.dart';
export 'ui/screens/image_picker_screen.dart';
export 'ui/screens/text_recognition_screen.dart';
export 'ui/screens/export_screen.dart';

// === INTERNAL IMPORTS ===
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'core/providers/document_provider.dart';
import 'ui/screens/home_screen.dart';

class OcrService {
  static void initializeService() async {
    WidgetsFlutterBinding.ensureInitialized();
  }

  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider(create: (_) => DocumentProvider()),
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
}
