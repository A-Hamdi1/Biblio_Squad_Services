import 'package:biblio_squad/visions/vision_model.dart';
import 'package:flutter/material.dart';
import 'vision_card.dart';

class VisionFeatures extends StatelessWidget {
  const VisionFeatures({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 0,
          childAspectRatio: 0.80,
        ),
        itemCount: visionFeatures.length,
        itemBuilder: (context, index) {
          return CardComponent(
            vision: visionFeatures[index],
            onPress: () => visionFeatures[index].onPress(context),
          );
        },
      ),
    );
  }
}
