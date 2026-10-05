import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String hintText;
  final Widget? prefixIcon;
  final Function(T?) onChanged;
  final String Function(T) itemToString;
  final String? Function(T?)? validator;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hintText,
    required this.onChanged,
    required this.itemToString,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      validator: validator,
      initialValue: value,
      builder: (FormFieldState<T> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: state.hasError ? AppColors.error : AppColors.slate300,
                  width: 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: value,
                  isExpanded: true,
                  hint: Row(
                    children: [
                      if (prefixIcon != null) ...[
                        prefixIcon!,
                        const SizedBox(width: 10),
                      ],
                      Text(hintText, style: const TextStyle(color: AppColors.slate500)),
                    ],
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.slate500),
                  items: items.map((T item) {
                    return DropdownMenuItem<T>(
                      value: item,
                      child: Text(itemToString(item)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    onChanged(val);
                    state.didChange(val);
                  },
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  state.errorText ?? "",
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
