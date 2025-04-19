import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../services/barcode_services.dart';
import 'barcode_provider.dart';

class BarcodeProviders {
  static List<SingleChildWidget> get providers => [
    // Services
    Provider<BarcodeServices>(
      create: (_) => BarcodeServices(),
      dispose: (_, service) => service.close(),
    ),

    // Providers
    ChangeNotifierProvider<BarcodeProvider>(
      create: (context) => BarcodeProvider(
        context.read<BarcodeServices>(),
      ),
    ),
  ];
}