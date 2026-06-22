import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget pullUpBar() {
  return Container(
    height: 6.7.h, // Adjust the height as needed
    width: 70.w, // Adjust the width as needed
    margin: EdgeInsets.symmetric(vertical: 8.h),
    decoration: BoxDecoration(
      color: Colors.grey[300], // Pull bar color
      borderRadius: BorderRadius.circular(4.r),
    ),
  );
}
