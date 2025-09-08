import 'package:flutter/material.dart';
import '../../themes/theme_exports.dart';

/// Reusable input field with focus effects and icon support
class AppInput extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final bool enabled;

  const AppInput({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  late TextEditingController _internalController;
  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);

    // Setup controller
    if (widget.controller != null) {
      _controller = widget.controller;
    } else {
      _internalController = TextEditingController();
      _controller = _internalController;
    }
    _controller!.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller?.removeListener(_handleTextChange);
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleTextChange() {
    setState(() {}); // Rebuild for opacity state
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 24.0;

    final bool hasContent = _controller?.text.isNotEmpty ?? false;
    final bool shouldHaveOpacity =
        !_isFocused && !hasContent && widget.errorText == null;

    // Main input container
    final inputField = Container(
      decoration: _isFocused && widget.errorText == null
          ? BoxDecoration(
              borderRadius: AppRadius.lg.radius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.lemon.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            )
          : null,
      child: Opacity(
        opacity: shouldHaveOpacity ? 0.5 : 1.0,
        child: TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
            helperText: widget.helperText,
            filled: true,
            fillColor: _getFillColor(context),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 12,
                    ), // Match Figma spacing
                    child: widget.prefixIcon,
                  )
                : null,
            prefixIconConstraints: widget.prefixIcon != null
                ? const BoxConstraints(
                    minWidth: iconSize,
                    minHeight: iconSize,
                    maxWidth: 56, // 24px icon + 32px total padding
                    maxHeight: iconSize,
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 20,
                    ), // Match Figma spacing
                    child: widget.suffixIcon,
                  )
                : null,
            suffixIconConstraints: widget.suffixIcon != null
                ? const BoxConstraints(
                    minWidth: iconSize,
                    minHeight: iconSize,
                    maxWidth: 56, // 24px icon + 32px total padding
                    maxHeight: iconSize,
                  )
                : null,
          ),
        ),
      ),
    );

    if (widget.label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label!,
            style: AppTypography.bodySubMedium.withColor(
              ThemeColors.textSecondary(context),
            ),
          ),
          AppSpacing.v2,
          inputField,
        ],
      );
    }

    return inputField;
  }

  Color? _getFillColor(BuildContext context) {
    // Error state
    if (widget.errorText != null) {
      return context.isDark
          ? DarkThemeColors.backgroundSecondary
          : LightThemeColors.backgroundSecondary;
    }

    // Focused state
    if (_isFocused) {
      return context.isDark
          ? DarkThemeColors.backgroundPrimary
          : LightThemeColors.backgroundPrimary;
    }

    // Default state
    return context.isDark
        ? DarkThemeColors.backgroundSecondary
        : LightThemeColors.backgroundSecondary;
  }
}
