import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/theme.dart';

Widget redDot() {
  return Container(
    width: 8.w,
    height: 8.h,
    decoration: const BoxDecoration(
      color: Themes.fire_red,
      shape: BoxShape.circle,
    ),
  );
}
