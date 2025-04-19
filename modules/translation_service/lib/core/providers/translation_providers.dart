import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../services/translation_services.dart';
import 'language_provider.dart';
import 'translation_provider.dart';

class TranslationProviders {
  static List<SingleChildWidget> get providers => [
    // Services
    Provider<TranslationServices>(
      create: (_) => TranslationServices(),
      dispose: (_, service) => service.close(),
    ),

    // Providers
    ChangeNotifierProvider<LanguageProvider>(
      create: (_) => LanguageProvider(),
    ),

    // Translation provider
    ChangeNotifierProvider<TranslationProvider>(
      create: (context) => TranslationProvider(
        context.read<TranslationServices>(),
      ),
    ),
  ];
}