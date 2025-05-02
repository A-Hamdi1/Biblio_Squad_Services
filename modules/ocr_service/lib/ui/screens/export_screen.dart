import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/document_provider.dart';
import '../../core/services/file_export_service.dart';
import '../components/app_button.dart';
import '../components/app_header.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({Key? key}) : super(key: key);

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
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

  Future<void> _saveAsTextFile() async {
    try {
      final filePath =
          await Provider.of<DocumentProvider>(context, listen: false)
              .saveTextToFile(format: ExportFormat.text);

      if (mounted && filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.fileSaved} $filePath'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.saveError}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _shareText() async {
    try {
      await Provider.of<DocumentProvider>(context, listen: false).shareText();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing text: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isLargeScreen = constraints.maxWidth > 600;

          return SafeArea(
            child: Column(
              children: [
                AppHeader(
                  onBackPressed: () => Navigator.pop(context),
                  showBar: true,
                ),
                Expanded(
                  child: Consumer<DocumentProvider>(
                    builder: (context, documentProvider, child) {
                      final text =
                          documentProvider.currentDocument?.extractedText ??
                              AppStrings.noTextFound;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isLargeScreen ? 600 : double.infinity,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  AppStrings.exportInstruction,
                                  style: TextStyle(fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.primary, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  constraints:
                                      const BoxConstraints(maxHeight: 300),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      text,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                AppButton(
                                  label: AppStrings.copyText,
                                  icon: Icons.copy,
                                  onPressed: _copyToClipboard,
                                ),
                                const SizedBox(height: 16),
                                AppButton(
                                  label: AppStrings.saveAsTextFile,
                                  icon: Icons.save_alt,
                                  onPressed: _saveAsTextFile,
                                ),
                                const SizedBox(height: 16),
                                AppButton(
                                  label: "Share Text",
                                  icon: Icons.share,
                                  onPressed: _shareText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
