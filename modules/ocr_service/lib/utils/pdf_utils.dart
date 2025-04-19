import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

class PdfUtils {
  Future<Uint8List> generatePdf(String text) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(text, style: pw.TextStyle(fontSize: 18)),
        ),
      ),
    );

    return Uint8List.fromList(await pdf.save());
  }

  Future<File> savePdf(String text, String filePath) async {
    final pdfBytes = await generatePdf(text);
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    return file;
  }
}
