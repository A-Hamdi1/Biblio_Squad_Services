// translation_api.dart
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationApi {
  static Future<String?> translateText(String recognizedText, TranslateLanguage targetLanguage) async {
    try {
      final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
      final sourceLanguageCode = await languageIdentifier.identifyLanguage(recognizedText);
      await languageIdentifier.close();

      final sourceLanguage = TranslateLanguage.values.firstWhere(
            (element) => element.bcpCode == sourceLanguageCode,
        orElse: () => TranslateLanguage.english,
      );

      final translator = OnDeviceTranslator(
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      final translatedText = await translator.translateText(recognizedText);
      await translator.close();

      return translatedText;
    } catch (e) {
      print('Translation error: $e');
      return null;
    }
  }
}
