import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/document_provider.dart';
import '../../core/providers/pdf_provider.dart';
import '../widgets/home_header.dart';

class PdfExportScreen extends StatefulWidget {
  const PdfExportScreen({super.key});

  @override
  _PdfExportScreenState createState() => _PdfExportScreenState();
}

class _PdfExportScreenState extends State<PdfExportScreen> {

  Future<void> _copyToClipboard() async {
    final text = Provider.of<DocumentProvider>(context, listen: false)
        .currentDocument?.extractedText ?? '';

    try {
      await Clipboard.setData(ClipboardData(text: text));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Texte copié!'),
          duration: Duration(milliseconds: 800),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la copie'),
          backgroundColor: Colors.red,
        ),
      );
    }

  }
  Future<void> _savePdf() async {
    final text = Provider.of<DocumentProvider>(context, listen: false)
        .currentDocument?.extractedText ?? '';

    await Provider.of<PdfProvider>(context, listen: false).savePdf(text);

    final pdfProvider = Provider.of<PdfProvider>(context, listen: false);

    if (pdfProvider.errorMessage.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(pdfProvider.errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else if (pdfProvider.savedFilePath.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("PDF Saved"),
          content: Text("PDF saved at: ${pdfProvider.savedFilePath}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
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
                HomeHeader(
                  svgSrc: "packages/ocr_service/assets/images/arrow_left.svg",
                  press: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Consumer<DocumentProvider>(
                    builder: (context, documentProvider, child) {
                      final text = documentProvider.currentDocument?.extractedText ?? 'No text available';

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
                                  "Your extracted text is ready to be saved as a PDF.",
                                  style: TextStyle(fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Color(0xFFFF7643), width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      text,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.copy, color: Colors.white),
                                  label: const Text("Copier le texte"),
                                  onPressed: _copyToClipboard,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: const Color(0xFFFF7643),
                                    textStyle: const TextStyle(fontSize: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Consumer<PdfProvider>(
                                    builder: (context, pdfProvider, child) {
                                      return ElevatedButton.icon(
                                        icon: const Icon(Icons.save_alt, color: Colors.white),
                                        label: pdfProvider.isSaving
                                            ? const Text("Saving...")
                                            : const Text("Save as PDF"),
                                        onPressed: pdfProvider.isSaving ? null : _savePdf,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          backgroundColor: Color(0xFFFF7643),
                                          textStyle: const TextStyle(fontSize: 18),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    }
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