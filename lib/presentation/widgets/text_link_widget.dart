import 'package:ecommerce_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart'; // Import your colors

class TextLinkWidget extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? textColor;
  final Color? linkColor;
  final bool showArrow;

  const TextLinkWidget({
    super.key,
    required this.text,
    required this.linkText,
    required this.onPressed,
    this.icon,
    this.textColor,
    this.linkColor,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: linkColor ?? AppColors.primaryColor),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              linkText,
              style: TextStyle(
                fontSize: 16,
                color: linkColor ?? AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: linkColor ?? AppColors.primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
