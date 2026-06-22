import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/theme.dart';

AppBar CustomAppBar() {
  return AppBar(
    title: Padding(
      padding: EdgeInsets.all(8.0.r),
      child: Text(
        "ZION",
        style: Themes.headline.copyWith(
          color: Themes.fire_red,
          fontSize: 34.sp,
          letterSpacing: -2.37,
        ),
      ),
    ),
    backgroundColor: Themes.white0,
  );
}
