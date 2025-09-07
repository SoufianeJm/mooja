import 'package:flutter/material.dart';
import '../../themes/theme_exports.dart';

enum ButtonVariant { primary, secondary, tertiary }

/// Reusable button component with three style variants
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final TextAlign textAlign;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.leftIcon,
    this.rightIcon,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.textAlign = TextAlign.center,
  });

  const AppButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? leftIcon,
    Widget? rightIcon,
    bool isLoading = false,
    bool isFullWidth = true,
    TextAlign textAlign = TextAlign.center,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         leftIcon: leftIcon,
         rightIcon: rightIcon,
         variant: ButtonVariant.primary,
         isLoading: isLoading,
         isFullWidth: isFullWidth,
         textAlign: textAlign,
       );

  const AppButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? leftIcon,
    Widget? rightIcon,
    bool isLoading = false,
    bool isFullWidth = true,
    TextAlign textAlign = TextAlign.center,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         leftIcon: leftIcon,
         rightIcon: rightIcon,
         variant: ButtonVariant.secondary,
         isLoading: isLoading,
         isFullWidth: isFullWidth,
         textAlign: textAlign,
       );

  const AppButton.tertiary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Widget? leftIcon,
    Widget? rightIcon,
    bool isLoading = false,
    bool isFullWidth = true,
    TextAlign textAlign = TextAlign.center,
  }) : this(
         key: key,
         text: text,
         onPressed: onPressed,
         leftIcon: leftIcon,
         rightIcon: rightIcon,
         variant: ButtonVariant.tertiary,
         isLoading: isLoading,
         isFullWidth: isFullWidth,
         textAlign: textAlign,
       );

  @override
  Widget build(BuildContext context) {
    const double iconSize = 22.0;
    const Widget iconGap = AppSpacing.h3;

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          if (text.isNotEmpty) iconGap,
        ] else if (leftIcon != null) ...[
          SizedBox(width: iconSize, height: iconSize, child: leftIcon!),
          iconGap,
        ],
        if (isFullWidth)
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium,
              textAlign: textAlign,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Flexible(
            child: Text(
              text,
              style: AppTypography.bodyMedium,
              textAlign: textAlign,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (rightIcon != null && !isLoading) ...[
          iconGap,
          SizedBox(width: iconSize, height: iconSize, child: rightIcon!),
        ],
      ],
    );

    Widget button = switch (variant) {
      ButtonVariant.primary => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: content,
      ),
      ButtonVariant.secondary => FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: content,
      ),
      ButtonVariant.tertiary => TextButton(
        onPressed: isLoading ? null : onPressed,
        child: content,
      ),
    };

    // Apply full width wrapper when needed
    if (isFullWidth) return SizedBox(width: double.infinity, child: button);
    return button;
  }
}
