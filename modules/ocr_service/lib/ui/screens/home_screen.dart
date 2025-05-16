import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../ui/screens/image_picker_screen.dart';
import '../components/app_button.dart';
import '../components/app_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget _buildHeader() {
    return SafeArea(
      child: Column(
        children: <Widget>[
          AppHeader(onBackPressed: () => Navigator.pop(context), showBar: true),
          const Spacer(),
          const Text(
            AppStrings.homeTitle,
            style: TextStyle(
              fontSize: 32,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            AppStrings.homeSubtitle,
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
          Image.asset(
            "assets/images/logo.png",
            height: 265,
            width: 235,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: _buildHeader(),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      const Spacer(flex: 3),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AppButton(
                          label: AppStrings.galleryButton,
                          icon: Icons.image,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ImagePickerScreen(source: "gallery"),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AppButton(
                          label: AppStrings.cameraButton,
                          icon: Icons.camera_alt_outlined,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ImagePickerScreen(source: "camera"),
                              ),
                            );
                          },
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
