import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class FloatingAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingAddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.financial,
      elevation: 6,
      child: const Icon(Icons.add, size: 28),
    ).animate().scale(
      duration: 300.ms,
      curve: Curves.easeOutBack,
    );
  }
}
