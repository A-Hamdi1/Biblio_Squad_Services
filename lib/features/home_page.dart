import 'package:barcode_service/barcode_service.dart';
import 'package:document_scan_service/document_scan_service.dart';
import 'package:flutter/material.dart';
import 'package:ocr_service/ocr_service.dart';
import 'package:translation_service/translation_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblio Squad'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildServiceIcon(
            context,
            icon: Icons.document_scanner,
            label: 'Text Recognition',
            onTap: () {
              OcrService.navigateToHomeScreen(context);

            },
          ),
          _buildServiceIcon(
            context,
            icon: Icons.translate,
            label: 'Translate',
            onTap: () {
              // TODO: Naviguer vers le module de traduction
              TranslationService.navigateToTranslationScreen(context);
            },
          ),
          _buildServiceIcon(
            context,
            icon: Icons.translate,
            label: 'Barcode Scanner',
            onTap: () {
              // TODO: Naviguer vers le module de Barcode Scanner
              BarcodeService.navigateToBarcodeScanScreen(context);
            },
          ),
          _buildServiceIcon(
            context,
            icon: Icons.translate,
            label: 'Document Scanner',
            onTap: () {
              // TODO: Naviguer vers le module de Barcode Scanner
              DocumentScanService.navigateToHomeScreen(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceIcon(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
