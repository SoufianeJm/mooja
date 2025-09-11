import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/themes/theme_exports.dart';
import '../../../core/widgets/app_chip.dart';

class DateSectionHeader extends StatelessWidget {
  static const double _pillRotationDegrees = -5.0;
  static const Color _pillBackgroundColor = AppColors.purple;
  static const Color _titleColor = AppColors.frost900;
  
  final String title;
  final String date;
  final Color? pillColor;
  
  const DateSectionHeader({
    super.key,
    required this.title,
    required this.date,
    this.pillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.h1SemiBold.copyWith(
                color: _titleColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          8.h,
          Transform.rotate(
            angle: _pillRotationDegrees * math.pi / 180,
            child: AppChip(
              label: date,
              backgroundColor: pillColor ?? _pillBackgroundColor,
            ),
        ),
      ],
    );
  }
}
