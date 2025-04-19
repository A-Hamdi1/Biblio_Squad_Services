import 'package:barcode_service/barcode_service.dart';
import 'package:ocr_service/ocr_service.dart';
import 'package:provider/single_child_widget.dart';
import 'package:translation_service/translation_service.dart';

List<SingleChildWidget> getGlobalProviders() => [
  ...OcrService.getProviders(),
  ...TranslationService.getProviders(),
  ...BarcodeService.getProviders(),

];
