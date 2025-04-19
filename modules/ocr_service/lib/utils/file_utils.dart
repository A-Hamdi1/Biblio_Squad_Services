import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<String> getFilePath() async {
    final directory = await getExternalStorageDirectory();
    return "${directory!.path}/document_scan.pdf";
  }
}
