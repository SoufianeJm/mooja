import 'package:flutter/material.dart';
import '../../../core/themes/theme_exports.dart';

enum TabType { forYou, forOrganizations }

class TabNavigation extends StatelessWidget {
  final TabType activeTab;
  final Function(TabType) onTabChanged;

  const TabNavigation({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabItem(
          label: 'For Organizations',
          isActive: activeTab == TabType.forOrganizations,
          onTap: () => onTabChanged(TabType.forOrganizations),
        ),
        24.h,
        _TabItem(
          label: 'For you',
          isActive: activeTab == TabType.forYou,
          onTap: () => onTabChanged(TabType.forYou),
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.h2SemiBold.copyWith(
              color: isActive
                  ? ThemeColors.textPrimary(context)
                  : ThemeColors.textSecondary(context),
            ),
          ),
          18.v,
          Container(
            width: 28,
            height: 2,
            decoration: BoxDecoration(
              color: isActive
                  ? ThemeColors.textPrimary(context)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}
