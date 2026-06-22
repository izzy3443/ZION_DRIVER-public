import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/theme.dart';

Widget customIconTextButton(
  String text,
  IconData icon, {
  VoidCallback? onPressed,
  double fontSize = 15.0,
  Color backgroundColor = const Color(0xFFFFEBEE),
  Color fontColor = Themes.fire_red,
}) {
  return SizedBox(
    width: double.infinity,
    child: TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: fontColor),
      label: Text(text,
          style: Themes.SmallContainerText.copyWith(
            fontSize: fontSize,
            color: fontColor,
            fontWeight: FontWeight.w600,
          )),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        backgroundColor: backgroundColor,
      ),
    ),
  );
}
