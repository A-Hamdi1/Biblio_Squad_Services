library auth_service;

// Export models
export 'models/user_model.dart';

// Export screens
export 'ui/screens/login_screen.dart';
export 'ui/screens/register_screen.dart';

// Main service
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'core/providers/auth_provider.dart';
import 'ui/screens/login_screen.dart';

/// AuthService is the main entry point for the authentication module.
class AuthService {
  static void initializeService() {
    // No specific initialization required for Firebase Auth
    // Firebase is already initialized in main.dart
  }

  /// Navigate to the login screen from any context
  static void navigateToLoginScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: getProviders(),
          child: const LoginScreen(),
        ),
      ),
    );
  }

  /// Get the providers required for this module
  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ];
  }
}
