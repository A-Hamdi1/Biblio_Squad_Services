import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/document_provider.dart';
import 'category_button.dart';
import '../screens/document_category_screen.dart';

class MenuCategories extends StatelessWidget {
  const MenuCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final documentProvider = Provider.of<DocumentProvider>(context, listen: false);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            CategoryButton(
              imagePath: null,
              label: 'Pamphlet',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DocumentCategoryPage(
                            categoryTitle: 'Pamphlet'))).then((_) {
                  // Refresh documents when returning to this screen
                  documentProvider.loadDocuments();
                });
              },
            ),
            const SizedBox(width: 16),
            CategoryButton(
              imagePath: null,
              label: 'Poetry ',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const DocumentCategoryPage(categoryTitle: 'Poetry'))).then((_) {
                  // Refresh documents when returning to this screen
                  documentProvider.loadDocuments();
                });
              },
            ),
            const SizedBox(width: 16),
            CategoryButton(
              imagePath: null,
              label: 'Novel',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                        const DocumentCategoryPage(categoryTitle: 'Novel'))).then((_) {
                  documentProvider.loadDocuments();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}