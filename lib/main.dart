import 'package:biblio_squad/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/global_providers.dart';
import 'features/home_page.dart';
import 'package:auth_service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // BarcodeService.initializeService();
  // TranslationService.initializeService();
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
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
