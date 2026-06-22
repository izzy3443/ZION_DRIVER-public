import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/theme.dart';

void showCustomSnackBar(
  BuildContext context,
  String message, {
  IconData? icon,
  Color? backgroundColor,
  Color? textColor,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  final snackBar = SnackBar(
    content: Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor ?? Colors.white,
              size: 24,
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Text(message,
                style: Themes.buttonTextlogin.copyWith(
                  color: textColor ?? Colors.white,
                )),
          ),
        ],
      ),
    ),
    backgroundColor:
        backgroundColor?.withOpacity(0.9) ?? Colors.grey[800]?.withOpacity(0.9),
    duration: duration,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
