import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/document_provider.dart';
import '../components/app_button.dart';
import '../components/app_header.dart';
import '../screens/text_recognition_screen.dart';

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
      Provider.of<DocumentProvider>(context, listen: false)
          .clearCurrentDocument();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TextRecognitionScreen(imageFile: _selectedImage!),
        ),
      );
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
            AppHeader(
              onBackPressed: () {
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
                      AppStrings.pickImageInstruction,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 80),

                    _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.info,
                          )
                        : _selectedImage == null
                            ? const Text(AppStrings.noImageSelected)
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

                    AppButton(
                      label: AppStrings.pickAnotherImage,
                      icon: Icons.refresh,
                      onPressed: _pickImage,
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
