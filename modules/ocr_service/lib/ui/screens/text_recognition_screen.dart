import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/document_provider.dart';
import '../components/app_button.dart';
import '../components/app_header.dart';
import '../screens/export_screen.dart';

class TextRecognitionScreen extends StatefulWidget {
  final File imageFile;

  const TextRecognitionScreen({super.key, required this.imageFile});

  @override
  _TextRecognitionScreenState createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  bool _isImageVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DocumentProvider>(context, listen: false)
          .processImage(widget.imageFile);
    });
  }

  Future<void> _copyToClipboard() async {
    final text = Provider.of<DocumentProvider>(context, listen: false)
            .currentDocument
            ?.extractedText ??
        '';

    try {
      await Clipboard.setData(ClipboardData(text: text));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.textCopied),
            duration: Duration(milliseconds: 800),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.textCopyError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<DocumentProvider>(
          builder: (context, documentProvider, child) {
            if (documentProvider.isProcessing) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }

            final document = documentProvider.currentDocument;
            final extractedText =
                document?.extractedText ?? AppStrings.noTextFound;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: AppHeader(
                    onBackPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppButton(
                            label: AppStrings.showImage,
                            icon: Icons.image,
                            onPressed: () {
                              setState(() {
                                _isImageVisible = !_isImageVisible;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          if (_isImageVisible)
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  widget.imageFile,
                                  fit: BoxFit.contain,
                                  height: 300,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.primary, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: SingleChildScrollView(
                              child: Text(
                                extractedText,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      AppButton(
                        label: AppStrings.copyText,
                        icon: Icons.copy,
                        onPressed: _copyToClipboard,
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: AppStrings.exportText,
                        icon: Icons.save_alt,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExportScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
