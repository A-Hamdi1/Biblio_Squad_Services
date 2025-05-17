import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.svgSrc, required this.press});

  final String svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconBtn(
            svgSrc: svgSrc,
            press: press,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              onChanged: (value) {},
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 186, 182, 182)
                    .withValues(alpha: 26),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: specialOutlineInputBorder,
                focusedBorder: specialOutlineInputBorder,
                enabledBorder: specialOutlineInputBorder,
                hintText: "Biblio Squad",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                      "packages/document_scan_service/assets/images/logo.png",
                      width: 24,
                      height: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const specialOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(20)),
  borderSide: BorderSide.none,
);

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
