import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zion_driver_553/UI/smallUI.dart';
import 'package:zion_driver_553/theme.dart';

Widget PlaceTile({
  required String label,
  IconData? icon,
  void Function()? onTap,
  Color? backgroundColor,
  Color? iconColor,
}) {
  return Padding(
    padding: EdgeInsets.only(right: 12.w, bottom: 10.h),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? Themes.white2,
          borderRadius: BorderRadius.circular(17.r),
          boxShadow: boxShadow(),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: iconColor ?? Themes.black0,
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              label[0].toUpperCase() + label.substring(1),
              style: Themes.MidContainerText.copyWith(color: Themes.gray3),
            ),
          ],
        ),
      ),
    ),
  );
}
