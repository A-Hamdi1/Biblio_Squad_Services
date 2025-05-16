import 'package:auth_service/auth_service.dart';
import 'package:biblio_squad/visions/vision_model.dart';
import 'package:flutter/material.dart';
import 'vision_card.dart';

class VisionFeatures extends StatelessWidget {
  const VisionFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.getCurrentUser(context);

    return FutureBuilder<List<VisionFeaturesModel>>(
      future: getVisionFeatures(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final allFeatures = snapshot.data ?? [];
        final features = allFeatures
            .where((feature) => feature.hasAccess(currentUser))
            .toList();
        if (features.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Vous n'avez pas accès aux fonctionnalités. Veuillez contacter un administrateur.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 0,
              childAspectRatio: 0.80,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              return CardComponent(
                vision: features[index],
                onPress: () => features[index].onPress(context),
              );
            },
          ),
        );
      },
    );
  }
}
