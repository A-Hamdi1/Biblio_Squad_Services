import 'package:auth_service/auth_service.dart';
import 'package:barcode_service/barcode_service.dart';
import 'package:document_scan_service/document_scan_service.dart';
import 'package:gestion_users_service/gestion_users_service.dart';
import 'package:ocr_service/ocr_service.dart';
import 'package:provider/single_child_widget.dart';
import 'package:translation_service/translation_service.dart';
// import 'package:smart_reply_service/smart_reply_service.dart';

List<SingleChildWidget> getGlobalProviders() => [
      ...OcrService.getProviders(),
      ...TranslationService.getProviders(),
      ...BarcodeService.getProviders(),
      ...DocumentScanService.getProviders(),
      ...AuthService.getProviders(),
      ...GestionUsersService.getProviders(),
      // ...SmartReplyService.getProviders(),
    ];
