import 'package:auth_service/auth_service.dart';
import 'package:auth_service/core/providers/auth_provider.dart';
import 'package:document_scan_service/ui/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
              svgSrc: "assets/images/logout.svg",
              press: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
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
