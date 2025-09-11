import 'package:ecommerce_app/core/constants/app_colors.dart';
import 'package:ecommerce_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final bool isRequired;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.isRequired = false,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isRequired) _buildRequiredLabel(theme),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            validator: widget.validator ?? _defaultValidator,
            maxLines: widget.maxLines,
            style: const TextStyle(fontSize: 16),
            decoration: _buildInputDecoration(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildRequiredLabel(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            widget.labelText,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const Text(
            ' *',
            style: TextStyle(
              color: AppColors.errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      labelText: widget.isRequired ? null : widget.labelText,
      hintText: widget.hintText,

      // Fix label and hint colors for dark theme
      labelStyle: TextStyle(
        color: _isFocused
            ? AppColors.primaryColor
            : (isDark ? Colors.white70 : AppColors.textSecondary),
      ),
      hintStyle: TextStyle(
        color: isDark ? Colors.white54 : AppColors.textTertiary,
      ),

      prefixIcon: widget.prefixIcon != null
          ? Icon(
              widget.prefixIcon,
              size: 20,
              color: _isFocused
                  ? AppColors.primaryColor
                  : (isDark ? Colors.white70 : AppColors.textSecondary),
            )
          : null,
      suffixIcon: widget.isPassword ? _buildPasswordToggle() : null,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(
          color: isDark ? Colors.white30 : AppColors.inputBorderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(
          color: isDark ? Colors.white30 : AppColors.inputBorderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: AppColors.errorColor, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        borderSide: BorderSide(color: AppColors.errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: _isFocused
          ? AppColors.primaryColor.withOpacity(0.05)
          : (isDark ? Colors.grey[850] : AppColors.inputFillColor),
    );
  }

  Widget _buildPasswordToggle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility_off : Icons.visibility,
        color: _isFocused
            ? AppColors.primaryColor
            : (isDark
                  ? Colors.white70
                  : Theme.of(context).textTheme.bodyMedium?.color),
        size: 20,
      ),
      onPressed: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '${widget.labelText} is required';
    }

    if (widget.keyboardType == TextInputType.emailAddress) {
      if (!_isValidEmail(value)) {
        return AppConstants.emailInvalid;
      }
    }

    if (widget.isPassword && value.length < 6) {
      return AppConstants.passwordTooShort;
    }

    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
