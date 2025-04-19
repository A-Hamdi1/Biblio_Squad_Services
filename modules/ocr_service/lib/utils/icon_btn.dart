import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconBtn extends StatelessWidget {
  const IconBtn({super.key, required this.svgSrc, required this.press});

  final String svgSrc;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: press,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Color(0xFF979797).withValues(alpha: 26),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(svgSrc),
          ),
        ],
      ),
    );
  }
}
