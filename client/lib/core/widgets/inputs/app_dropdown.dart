import 'package:flutter/material.dart';
import '../../themes/app_radius.dart';
import '../../themes/app_spacing.dart';
import '../../themes/typography.dart';
import '../../themes/app_colors.dart';

class AppDropdownItem<T> {
  final T value;
  final String label;
  final Widget? leftIcon;
  final Widget? rightIcon;

  const AppDropdownItem({
    required this.value,
    required this.label,
    this.leftIcon,
    this.rightIcon,
  });
}

class AppDropdown<T> extends StatefulWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.leftIcon,
    this.rightIcon,
    this.validator,
  });

  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String? hint;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final String? Function(T?)? validator;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 8, // 8px gap
        width: size.width,
        child: Material(
          elevation: 8,
          borderRadius: AppRadius.md.radius,
          child: Container(
            decoration: BoxDecoration(
              color: ThemeColors.backgroundSecondary(context),
              borderRadius: AppRadius.md.radius,
            ),
            child: Column(
              children: widget.items.map((item) {
                return GestureDetector(
                  onTap: () => _selectItem(item),
                  child: Container(
                    width: double.infinity,
                    padding: 20.ph + 15.pv,
                    child: Row(
                      children: [
                        if (item.leftIcon != null) ...[
                          SizedBox(width: 22, height: 22, child: item.leftIcon),
                          AppSpacing.s3.h,
                        ],
                        Expanded(
                          child: Text(
                            item.label,
                            style: AppTypography.bodyMedium.copyWith(
                              color: ThemeColors.textPrimary(context),
                            ),
                          ),
                        ),
                        if (item.rightIcon != null) ...[
                          AppSpacing.s3.h,
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: item.rightIcon,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOpen = false;
    });
  }

  void _selectItem(AppDropdownItem<T> item) {
    _closeDropdown();
    widget.onChanged(item.value);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem = widget.items.firstWhere(
      (item) => item.value == widget.value,
      orElse: () => widget.items.first,
    );

    return GestureDetector(
      onTap: _toggleDropdown,
      child: Container(
        width: double.infinity,
        padding: 20.ph + 15.pv,
        decoration: BoxDecoration(
          color: ThemeColors.backgroundSecondary(context),
          borderRadius: AppRadius.md.radius,
        ),
        child: Row(
          children: [
            // Show selected item's left icon if available, otherwise show widget's left icon
            if (widget.value != null && selectedItem.leftIcon != null) ...[
              SizedBox(width: 22, height: 22, child: selectedItem.leftIcon),
              AppSpacing.s3.h,
            ] else if (widget.leftIcon != null) ...[
              SizedBox(width: 22, height: 22, child: widget.leftIcon),
              AppSpacing.s3.h,
            ],
            Expanded(
              child: Text(
                widget.value != null ? selectedItem.label : widget.hint ?? '',
                style: AppTypography.bodyMedium.copyWith(
                  color: widget.value != null
                      ? ThemeColors.textPrimary(context)
                      : ThemeColors.textSecondary(context),
                ),
              ),
            ),
            if (widget.rightIcon != null) ...[
              AppSpacing.s3.h,
              SizedBox(width: 22, height: 22, child: widget.rightIcon),
            ],
          ],
        ),
      ),
    );
  }
}
