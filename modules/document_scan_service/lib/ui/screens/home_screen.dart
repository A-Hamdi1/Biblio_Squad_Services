import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:provider/provider.dart';
import '../../ui/widgets/home_header.dart';
import '../../../core/providers/document_provider.dart';
import 'latest_documents_screen.dart';
import '../widgets/menu_categories.dart';
import 'save_document_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentProvider>().loadDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<DocumentProvider>(
          builder: (context, documentProvider, child) {
            return RefreshIndicator(
              onRefresh: () => documentProvider.loadDocuments(),
              child: Column(
                children: [
                  HomeHeader(svgSrc: "packages/document_scan_service/assets/images/arrow_left.svg", press: () {}),
                  Container(
                    margin: const EdgeInsets.fromLTRB(16.0, 16, 16, 0),
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 84, 180, 189),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Scan Card or Document',
                          style: TextStyle(
                            color: Color(0xffFFFFFF),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            minimumSize: const Size(200, 50),
                          ),
                          onPressed: () async {
                            DocumentScannerOptions documentOptions = DocumentScannerOptions(
                              documentFormat: DocumentFormat.jpeg,
                              mode: ScannerMode.filter,
                              pageLimit: 100,
                              isGalleryImport: true,
                            );

                            final documentScanner = DocumentScanner(options: documentOptions);
                            DocumentScanningResult result = await documentScanner.scanDocument();
                            final images = result.images;

                            if (images.isNotEmpty) {
                              if (context.mounted) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SaveDocumentPage(
                                      pathImage: images,
                                    ),
                                  ),
                                );
                                documentProvider.loadDocuments();
                              }
                            }
                          },
                          child: const Text(
                            'Scan Document',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const MenuCategories(),
                  const SizedBox(height: 20.0),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Latest Documents',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  documentProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                    child: documentProvider.documents.isEmpty
                        ? const Center(child: Text("No documents found"))
                        : LatestDocumentsPage(
                      documents: documentProvider.documents,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}