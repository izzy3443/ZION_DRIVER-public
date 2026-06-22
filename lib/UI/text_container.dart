import 'package:flutter/material.dart';
import 'package:zion_driver_553/theme.dart';

Widget appMessageContainer({
  required String message,
  IconData? icon,
  Color? backgroundColor,
  Color? textColor,
  EdgeInsetsGeometry? padding,
}) {
  return Container(
    padding:
        padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: (backgroundColor ?? Colors.grey[850])!.withOpacity(0.9),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: textColor ?? Themes.white0,
            size: 22,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(message, style: Themes.buttonText),
        ),
      ],
    ),
  );
}
