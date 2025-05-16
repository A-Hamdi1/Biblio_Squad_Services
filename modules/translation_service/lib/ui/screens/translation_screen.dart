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
          // Create a proper language name map with proper formatting
          final languageNames = {
            for (var lang in TranslateLanguage.values)
              lang: _formatLanguageName(lang.name),
          };

          return Column(
            children: [
              // Top Bar with Language Selector
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: GlassCard2(
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            // Language icon (always visible)
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF7643).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.language,
                                size: 20,
                                color: Color(0xFFFF7643),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Selected language display and dropdown
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<TranslateLanguage>(
                                  value: provider.selectedLanguage,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: Color(0xFFFF7643)),
                                  hint: const Text("Select language"),
                                  // Display the current language name
                                  selectedItemBuilder: (BuildContext context) {
                                    return languageNames.entries
                                        .map<Widget>((entry) {
                                      return Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          entry.value,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  },
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
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                        bottom: 85,
                        left: 10,
                        right: 10,
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: GlassCard2(
                            expand: false,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0,
                                  bottom: 20.0,
                                  left: 10.0,
                                  right: 10.0),
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
                        bottom: 85,
                        left: 10,
                        right: 10,
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: GlassCard2(
                            expand: false,
                            backgroundColor: Color(0x55EF5350),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0,
                                  bottom: 20.0,
                                  left: 10.0,
                                  right: 10.0),
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
                      bottom: 20,
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
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFF7643).withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              gradient: LinearGradient(
                                colors: provider.isProcessing
                                    ? [Colors.grey, Colors.grey]
                                    : [Color(0xFFFF7643), Color(0xFFFF7643)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
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

  // Helper method to properly format language names
  String _formatLanguageName(String name) {
    // Replace underscores with spaces and properly capitalize words
    final words = name.split('_');
    return words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

class GlassCard2 extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? height;
  final bool expand;

  const GlassCard2({
    required this.child,
    this.backgroundColor,
    this.height,
    this.expand = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      height: height,
      padding: height != null ? EdgeInsets.zero : const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white70,
        border: Border.all(color: Color(0xFFFF7643), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: child,
      ),
    );

    return expand
        ? Expanded(child: SingleChildScrollView(child: container))
        : container;
  }
}
