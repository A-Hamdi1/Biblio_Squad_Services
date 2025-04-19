import 'package:biblio_squad/visions/vision_model.dart';
import 'package:flutter/material.dart';

class CardComponent extends StatelessWidget {
  const CardComponent({
    super.key,
    this.width = 120,
    this.aspectRetio = 1.02,
    required this.vision,
    required this.onPress,
  });

  final double width, aspectRetio;
  final VisionFeaturesModel vision;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: aspectRetio,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF979797).withValues(alpha: 26),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // Shadow color
                      spreadRadius: 2, // How far the shadow spreads
                      blurRadius: 8, // How blurry the shadow is
                      offset: const Offset(0, 4), // Shadow position (x, y)
                    ),
                  ],
                ),
                child: Image.asset(vision.image, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                vision.title,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}