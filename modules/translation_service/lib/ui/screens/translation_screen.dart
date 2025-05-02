import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';
import '../../core/providers/translation_provider.dart';

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TranslationProvider>(
        builder: (context, provider, child) {
          final languageNames = {
            for (var lang in TranslateLanguage.values)
              lang: lang.name[0].toUpperCase() + lang.name.substring(1),
          };

          return Column(
            children: [
              // Top Bar with Language Selector
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: GlassCard(
                      height: 50,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.language,
                            size: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<TranslateLanguage>(
                                value: provider.selectedLanguage,
                                onChanged: (lang) {
                                  if (lang != null) {
                                    provider.setSelectedLanguage(lang);
                                  }
                                },
                                items: languageNames.entries.map((entry) {
                                  return DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(
                                      entry.value,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Camera Preview
              Expanded(
                child: Stack(
                  children: [
                    // Camera Preview
                    if (provider.cameraController != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CameraPreview(provider.cameraController!),
                      )
                    else
                      const Center(child: CircularProgressIndicator.adaptive()),

                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF121212).withOpacity(0.3),
                            Colors.transparent,
                            Color(0xFF121212).withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),

                    // Translation Result
                    if (provider.currentTranslation?.translatedText != null)
                      Positioned(
                        bottom: 100,
                        left: 20,
                        right: 20,
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                provider.currentTranslation!.translatedText!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontSize: 22,
                                      letterSpacing: 0.5,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Error Message
                    if (provider.errorMessage != null)
                      Positioned(
                        bottom: 100,
                        left: 20,
                        right: 20,
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: GlassCard(
                            backgroundColor: Color(0x55EF5350),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 20.0),
                              child: Text(
                                provider.errorMessage!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: 18,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Translate Button
                    Positioned(
                      bottom: 30,
                      left: MediaQuery.of(context).size.width * 0.5 - 30,
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: GestureDetector(
                          onTap: provider.isProcessing
                              ? null
                              : provider.translateText,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: provider.isProcessing
                                    ? [Colors.grey, Colors.grey]
                                    : [Color(0xFF1E88E5), Color(0xFF00BCD4)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: provider.isProcessing
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : const Icon(
                                    Icons.translate,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? height;

  const GlassCard({
    required this.child,
    this.backgroundColor,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: backgroundColor ?? Color(0x33FFFFFF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Color(0x33FFFFFF).withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Color(0x4D000000).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
