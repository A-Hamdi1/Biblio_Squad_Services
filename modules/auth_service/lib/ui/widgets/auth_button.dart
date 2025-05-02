import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final TextStyle? textStyle; // Make textStyle optional
  final Color? backgroundColor; // Make backgroundColor optional

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textStyle,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: backgroundColor ??
            const Color(0xFFFF7643), // Default background color
        textStyle:
            textStyle ?? const TextStyle(fontSize: 18), // Default text style
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text),
    );
  }
}
