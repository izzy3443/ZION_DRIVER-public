import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zion_driver_553/theme.dart';

Widget buildStep(String stepNum, String text) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Themes.gray1,
          radius: 14,
          child: Text(stepNum, style: Themes.smallButtonText),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: Themes.subtitlesubText.copyWith(fontSize: 16.sp),
          ),
        ),
      ],
    ),
  );
}
