import '../../ui/screens/image_picker_screen.dart';
import '../widgets/home_header.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Widget buildTextContent() {
    return SafeArea(
      child: Column(
        children: <Widget>[
          HomeHeader(
            svgSrc: "packages/ocr_service/assets/images/arrow_left.svg",
            press: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Text(
            "TEXT RECOGNITION",
            style: TextStyle(
              fontSize: 32,
              color: Color(0xFFFF7643),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Make your choice!",
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
          Image.asset(
            "packages/ocr_service/assets/images/splash.png",
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
                child: buildTextContent(),
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
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.image,
                              color: Colors.white),
                          label: const Text("Gallery"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ImagePickerScreen(source: "gallery"),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Color(0xFFFF7643),
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt_outlined,
                              color: Colors.white),
                          label: const Text("Camera"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ImagePickerScreen(source: "camera"),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Color(0xFFFF7643),
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
