import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum AppButtonType { primary, secondary, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final AppButtonType type;
  final double? width;
  final double height;
  final double borderRadius;

  const AppButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.type = AppButtonType.primary,
    this.width,
    this.height = 50,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AppButtonType.primary:
        return _buildElevatedButton();
      case AppButtonType.secondary:
        return _buildOutlinedButton();
      case AppButtonType.text:
        return _buildTextButton();
    }
  }

  Widget _buildElevatedButton() {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton.icon(
        icon: icon != null
            ? Icon(icon, color: AppColors.buttonText)
            : Container(),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton() {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton.icon(
        icon: icon != null ? Icon(icon, color: AppColors.primary) : Container(),
        label: Text(label),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton() {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton.icon(
        icon: icon != null ? Icon(icon, color: AppColors.primary) : Container(),
        label: Text(label),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
