import 'package:flutter/material.dart';
import 'package:ninte/presentation/theme/app_colors.dart';

class ModalContainer extends StatelessWidget {
  final Widget child;
  final double? maxHeight;

  const ModalContainer({
    super.key,
    required this.child,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (child is! ScrollView) Expanded(child: child) else child,
        ],
      ),
    );
  }
} 