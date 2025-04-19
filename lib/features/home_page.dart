import 'package:document_scan_service/ui/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:translation_service/ui/screens/settings_screen.dart';

import '../visions/vision_features .dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(children: [
            HomeHeader(
              svgSrc: "assets/images/Settings.svg",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
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
