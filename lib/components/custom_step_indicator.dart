import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<IconData> icons;

  const CustomStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(totalSteps, (index) {
        bool isActive = index <= currentStep;
        bool isLast = index == totalSteps - 1;

        return Expanded(
          child: Column(
            children: [
              // Cercle de l'étape
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.slate200,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [BoxShadow(color: AppColors.primary.withAlpha(80), blurRadius: 8, offset: const Offset(0, 4))]
                      : [],
                ),
                child: Icon(
                  icons[index],
                  color: isActive ? AppColors.white : AppColors.slate500,
                  size: 20,
                ),
              ),
              // Ligne de connexion
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isActive && index < currentStep 
                        ? AppColors.primary 
                        : AppColors.slate200,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
