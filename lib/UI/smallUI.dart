import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/theme.dart';

Widget reusableListItem({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color iconColor,
  VoidCallback? onTap,
  Widget? trailing,
  Color? subtitleColor, // ✅ Optional subtitle color
}) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0.h),
      child: Container(
        decoration: BoxDecoration(
          color: Themes.white0,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: boxShadow(),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              _buildIcon(icon, iconColor),
              SizedBox(width: 14.w),
              _buildText(title, subtitle, subtitleColor),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildIcon(IconData icon, Color color) {
  return Container(
    width: 44.w,
    height: 44.h,
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Icon(
      icon,
      color: color,
      size: 24,
    ),
  );
}

Widget _buildText(String title, String subtitle, [Color? subtitleColor]) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Themes.MidContainerText,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        SizedBox(height: 3.h),
        Text(
          subtitle,
          style: Themes.SmallContainerText.copyWith(
            color: subtitleColor ?? Themes.SmallContainerText.color,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    ),
  );
}

List<BoxShadow> boxShadow() {
  return [
    BoxShadow(
      color: Themes.black0.withOpacity(0.07),
      spreadRadius: 1,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
}
