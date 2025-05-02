import 'package:biblio_squad/visions/vision_model.dart';
import 'package:flutter/material.dart';
import 'vision_card.dart';

class VisionFeatures extends StatelessWidget {
  const VisionFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VisionFeaturesModel>>(
      future: getVisionFeatures(context),
      builder: (context, snapshot) {
        // Directly render the grid with available data, default to empty list
        final features = snapshot.data ?? [];
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
