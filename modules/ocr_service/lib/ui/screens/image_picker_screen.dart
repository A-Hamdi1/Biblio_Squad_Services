import 'dart:io';
import '../../core/providers/document_provider.dart';
import 'text_recognition_screen.dart';
import 'package:provider/provider.dart';
import '../../ui/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerScreen extends StatefulWidget {
  final String source;

  const ImagePickerScreen({super.key, required this.source});

  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  File? _selectedImage;
  bool _isLoading = true;

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source:
      widget.source == "gallery" ? ImageSource.gallery : ImageSource.camera,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isLoading = false;
      });

      // Clear previous document data
      Provider.of<DocumentProvider>(context, listen: false).clearCurrentDocument();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TextRecognitionScreen(imageFile: _selectedImage!),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(
              svgSrc: "packages/ocr_service/assets/images/arrow_left.svg",
              press: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Instruction text
                    const Text(
                      'Please select or capture an image for text recognition.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 80),

                    _isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.blueAccent,
                    )
                        : _selectedImage == null
                        ? const Text("No image selected")
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.contain,
                        height: 380,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 40),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text("Pick Another Image"),
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Color(0xFFFF7643),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}