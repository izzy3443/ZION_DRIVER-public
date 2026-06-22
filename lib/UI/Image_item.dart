import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/UI/smallUI.dart';
import 'package:zion_driver_553/theme.dart';

Widget vehicleOptionItem({
  required String title,
  required String description,
  required String imagePath,
  bool isSelected = false,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
          color: Themes.white0,
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected
              ? Border.all(color: Themes.black0, width: 2.w)
              : Border.all(color: Themes.white3, width: 1.w),
          boxShadow: boxShadow()),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image

          SizedBox(width: 16.w),

          // Title & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Themes.subtitleText.copyWith(letterSpacing: -0.7)),
                SizedBox(height: 2.h),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "type".tr(), style: Themes.subtitlesubText),
                      TextSpan(
                          text: description, style: Themes.SmallContainerText),
                    ],
                  ),
                )
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(
              imagePath,
              width: 50.w,
              height: 50.h,
              fit: BoxFit.contain,
            ),
          ),

          // Selection Indicator (optional)
          if (isSelected)
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Themes.fire_red,
              ),
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            ),
        ],
      ),
    ),
  );
}
