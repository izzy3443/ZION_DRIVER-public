import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/UI/smallUI.dart';
import 'package:zion_driver_553/theme.dart';

Widget buildActivityCard({
  required String title,
  required String value,
  required String subtitle,
  required IconData icon,
  required Color color,
  required Color textColor,
  bool showProgress = false,
}) {
  return Container(
    padding: EdgeInsets.all(15.r),
    decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: boxShadow()),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: textColor == Colors.white
                    ? Colors.white.withOpacity(0.2)
                    : Themes.black0.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: textColor,
                size: 20,
              ),
            ),
            const Spacer(),
          ],
        ),
        SizedBox(height: 15.h),
        Text(
          title,
          style: (Themes.SmallContainerText).copyWith(
            color: textColor.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          style: Themes.headline3.copyWith(
            color: textColor,
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 5.h),
        Text(subtitle,
            style: Themes.SuperSmallContainerText.copyWith(
                color: textColor.withOpacity(0.7))),
      ],
    ),
  );
}
