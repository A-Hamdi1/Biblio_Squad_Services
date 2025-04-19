import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:translation_service/ui/screens/settings_screen.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/translation_provider.dart';
import '../widgets/translation_overlay.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final translationProvider = Provider.of<TranslationProvider>(context, listen: false);
        final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
        translationProvider.applyLanguageChange(languageProvider.targetLanguage);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final translationProvider =
    Provider.of<TranslationProvider>(context, listen: false);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      translationProvider.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Translator', style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );

              if (mounted) {
                final translationProvider = Provider.of<TranslationProvider>(context, listen: false);
                final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
                translationProvider.applyLanguageChange(languageProvider.targetLanguage);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer2<TranslationProvider, LanguageProvider>(
        builder: (context, translationProvider, languageProvider, child) {
          translationProvider.checkLanguageChange(languageProvider.targetLanguage);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              translationProvider.applyLanguageChange(languageProvider.targetLanguage);
            }
          });

          if (translationProvider.status == TranslationStatus.initializing) {
            return const Center(child: CircularProgressIndicator());
          }

          if (translationProvider.status == TranslationStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(translationProvider.errorMessage ?? 'An error occurred'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              if (translationProvider.cameraController != null)
                CameraPreview(translationProvider.cameraController!),
              TranslationOverlay(
                  translations: translationProvider.detectedTexts),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Target: ${languageProvider.supportedLanguages[languageProvider.targetLanguage] ?? 'Unknown'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer2<TranslationProvider, LanguageProvider>(
        builder: (context, translationProvider, languageProvider, _) {
          return FloatingActionButton(
            onPressed: () {
              translationProvider.captureAndTranslate(context);
            },
            child: translationProvider.status == TranslationStatus.processing
                ? const CircularProgressIndicator(color: Colors.white)
                : translationProvider.detectedTexts.isEmpty
                ? const Icon(Icons.translate)
                : const Icon(Icons.cleaning_services),
            tooltip: translationProvider.detectedTexts.isEmpty
                ? 'Translate'
                : 'Clear and translate again',
          );
        },
      ),
    );
  }
}
