import 'package:flutter/material.dart';
import '../../themes/theme_exports.dart';

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
  final TextCapitalization textCapitalization;

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
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _internalController;
  TextEditingController? _controller;
  late AnimationController _animationController;
  late Animation<double> _shadowAnimation;

  /// Focus change handler - stored as a named function for proper removal
  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _animationController.forward(); // Show yellow glow
    } else {
      _animationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _shadowAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Use named function for proper cleanup
    _focusNode.addListener(_onFocusChange);

    if (widget.controller != null) {
      _controller = widget.controller;
    } else {
      _internalController = TextEditingController();
      _controller = _internalController;
    }
  }

  @override
  void dispose() {
    // Remove listener before disposing to prevent memory leak
    _focusNode.removeListener(_onFocusChange);
    _animationController.dispose();
    _focusNode.dispose();
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  Color _getFillColor(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;

    if (_focusNode.hasFocus) {
      // White background on focus
      return context.isDark
          ? DarkThemeColors.backgroundPrimary
          : LightThemeColors.backgroundPrimary;
    }

    return inputTheme.fillColor ??
        (context.isDark
            ? DarkThemeColors.backgroundSecondary
            : LightThemeColors.backgroundSecondary);
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 24.0;

    // TextField rebuilds only on focus change for fillColor
    final textField = ListenableBuilder(
      listenable: _focusNode,
      builder: (context, child) {
        return TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
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
                    padding: const EdgeInsets.only(left: 20, right: 12),
                    child: widget.prefixIcon,
                  )
                : null,
            prefixIconConstraints: widget.prefixIcon != null
                ? const BoxConstraints(
                    minWidth: iconSize,
                    minHeight: iconSize,
                    maxWidth: 56,
                    maxHeight: iconSize,
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 20),
                    child: widget.suffixIcon,
                  )
                : null,
            suffixIconConstraints: widget.suffixIcon != null
                ? const BoxConstraints(
                    minWidth: iconSize,
                    minHeight: iconSize,
                    maxWidth: 56,
                    maxHeight: iconSize,
                  )
                : null,
          ),
        );
      },
    );

    // Shadow and opacity animations only
    final inputField = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final hasContent = _controller?.text.isNotEmpty ?? false;
        final isFocused = _focusNode.hasFocus;
        final shouldFade =
            !isFocused && !hasContent && widget.errorText == null;

        return Container(
          decoration: widget.errorText == null
              ? BoxDecoration(
                  borderRadius: AppRadius.md.radius,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lemon.withValues(
                        alpha: 0.25 * _shadowAnimation.value,
                      ),
                      blurRadius: 20 * _shadowAnimation.value,
                    ),
                  ],
                )
              : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: shouldFade ? 0.5 : 1.0,
            child: child,
          ),
        );
      },
      child: textField,
    );

    if (widget.label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
}
