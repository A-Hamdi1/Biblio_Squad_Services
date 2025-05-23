import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final bool showBar;

  const AppHeader({
    super.key,
    this.onBackPressed,
    this.showBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (onBackPressed != null)
            _buildBackButton()
          else
            const SizedBox(width: 46),

          // Search bar
          if (showBar) Expanded(child: _buildSpecialField()),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onBackPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 46,
        width: 46,
        child: const Icon(Icons.arrow_back, color: Colors.black),
      ),
    );
  }

  Widget _buildSpecialField() {
    return TextFormField(
      onChanged: (value) {},
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        border: specialOutlineInputBorder,
        focusedBorder: specialOutlineInputBorder,
        enabledBorder: specialOutlineInputBorder,
        hintText: "Biblio Squad",
        prefixIcon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("assets/images/logo.png", width: 24, height: 24),
        ),
      ),
    );
  }
}

const specialOutlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(20)),
  borderSide: BorderSide.none,
);
