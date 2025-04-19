import 'package:flutter/material.dart';
import '../../utils/icon_btn.dart';

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
                border: searchOutlineInputBorder,
                focusedBorder: searchOutlineInputBorder,
                enabledBorder: searchOutlineInputBorder,
                hintText: "Biblio Squad",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset("packages/ocr_service/assets/images/logo.png", width: 24, height: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const searchOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(20)),
  borderSide: BorderSide.none,
);
