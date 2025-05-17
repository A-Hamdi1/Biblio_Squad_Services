library gestion_users_service;

// Export models
export 'models/users_management_model.dart';

// Export screens
export 'ui/screens/users_list_screen.dart';
export 'ui/screens/user_details_screen.dart';

// Export providers
export 'core/providers/users_management_provider.dart';

// Main service
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'core/providers/users_management_provider.dart';
import 'ui/screens/users_list_screen.dart';

class GestionUsersService {
  static void initializeService() {}

  static void navigateToUsersListScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: getProviders(),
          child: const UsersListScreen(),
        ),
      ),
    );
  }

  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider(create: (_) => UsersManagementProvider()),
    ];
  }
}
