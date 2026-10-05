import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color>? gradientColors;
  final Color? color;
  final Color textColor;
  final IconData? icon;
  final double borderRadius;
  final double? width;
  final double? height;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradientColors,
    this.color,
    this.textColor = AppColors.white,
    this.icon,
    this.borderRadius = 30.0, // Style "Pill" par défaut
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    return SizedBox(
      width: width,
      height: height ?? 55, // Hauteur standard moderne
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: gradientColors != null
              ? LinearGradient(
                  colors: gradientColors!,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: (gradientColors?.first ?? effectiveColor).withAlpha(80),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: gradientColors != null ? AppColors.transparent : effectiveColor,
            foregroundColor: textColor,
            shadowColor: AppColors.transparent,
            disabledBackgroundColor: AppColors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: textColor,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      text,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
