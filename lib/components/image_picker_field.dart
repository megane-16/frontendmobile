import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ImagePickerField extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool hasImage;
  final File? imageFile;

  const ImagePickerField({
    super.key,
    required this.label,
    required this.onTap,
    this.hasImage = false,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage ? AppColors.primary : AppColors.slate300,
            style: BorderStyle.solid,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: hasImage && imageFile != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      imageFile!,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasImage ? Icons.check_circle : Icons.camera_alt,
                      color: hasImage ? AppColors.success : AppColors.slate400,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasImage ? "Photo ajoutée" : label,
                      style: TextStyle(
                        color: hasImage ? AppColors.success : AppColors.slate500,
                        fontWeight: hasImage ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
