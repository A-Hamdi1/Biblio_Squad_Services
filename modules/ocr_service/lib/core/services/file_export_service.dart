import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

enum ExportFormat { text, csv }

class FileExportService {
  // Singleton pattern
  static final FileExportService _instance = FileExportService._internal();

  factory FileExportService() => _instance;

  FileExportService._internal();

  /// Save text content to a file
  Future<String> saveTextToFile(String content,
      {String? filename, ExportFormat format = ExportFormat.text}) async {
    // Check storage permission
    if (!await _checkPermission()) {
      throw Exception("Storage permission denied");
    }

    // Get file extension
    final extension = format == ExportFormat.text ? 'txt' : 'csv';

    // Generate filename if not provided
    final String finalFilename = filename ??
        'document_${DateTime.now().millisecondsSinceEpoch}.$extension';

    try {
      // Get storage directory
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception("Could not access storage directory");
      }

      // Create and write to file
      final file = File('${directory.path}/$finalFilename');
      await file.writeAsString(content);

      return file.path;
    } catch (e) {
      throw Exception("Failed to save file: $e");
    }
  }

  /// Share text content with other apps
  Future<void> shareText(String content, {String? subject}) async {
    try {
      await Share.share(
        content,
        subject: subject ?? 'Shared Document Text',
      );
    } catch (e) {
      throw Exception("Failed to share content: $e");
    }
  }

  /// Share a file with other apps
  Future<void> shareFile(String filePath, {String? subject}) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject ?? 'Shared Document',
      );
    } catch (e) {
      throw Exception("Failed to share file: $e");
    }
  }

  /// Check if the app has storage permission
  Future<bool> _checkPermission() async {
    final status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.storage.request();
    return result.isGranted;
  }
}
