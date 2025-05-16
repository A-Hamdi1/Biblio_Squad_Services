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
import 'models/user_model.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/register_screen.dart';

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

  /// Navigate to the register screen from any context
  static void navigateToRegisterScreen(BuildContext context,
      {String initialRole = 'user'}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: getProviders(),
          child: RegisterScreen(initialRole: initialRole),
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

  /// Check if a user is authenticated
  static bool isAuthenticated(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAuthenticated;
  }

  /// Get the current user (if authenticated)
  static UserModel? getCurrentUser(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.currentUser;
  }

  /// Logout the current user
  static Future<void> logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
  }
}
