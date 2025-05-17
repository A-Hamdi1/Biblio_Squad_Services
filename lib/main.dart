import 'package:biblio_squad/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gestion_users_service/gestion_users_service.dart';
import 'package:provider/provider.dart';
import 'features/auth_wrapper.dart';
import 'features/global_providers.dart';
import 'pages/home_page.dart';
import 'package:auth_service/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // BarcodeService.initializeService();
  // TranslationService.initializeService();
  GestionUsersService.initializeService();
  AuthService.initializeService();
  runApp(const BiblioSquadApp());
}

class BiblioSquadApp extends StatelessWidget {
  const BiblioSquadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: getGlobalProviders(),
      child: MaterialApp(
        title: 'Biblio Squad',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(context),
        // home: const HomeScreen(),
        home: const AuthWrapper(),
      ),
    );
  }
}
