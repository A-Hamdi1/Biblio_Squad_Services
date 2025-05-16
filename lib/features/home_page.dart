import 'package:auth_service/auth_service.dart';
import 'package:document_scan_service/ui/widgets/home_header.dart';
import 'package:flutter/material.dart';
import '../visions/vision_features .dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(children: [
            HomeHeader(
              svgSrc: "assets/images/logout.svg",
              press: () async {
                await AuthService.logout(context);
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false);
                }
              },
            ),
            SizedBox(height: 50),
            VisionFeatures(),
          ]),
        ),
      ),
    );
  }
}
