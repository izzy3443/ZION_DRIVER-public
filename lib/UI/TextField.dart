import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zion_driver_553/UI/smallUI.dart';
import 'package:zion_driver_553/theme.dart';

Widget textField(
  TextEditingController textFieldController,
  String hintText, {
  FocusNode? focusNode, // Optional focus node
  IconData? icon, // Optional icon
  void Function(String)? onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: boxShadow(),
    ),
    child: TextField(
      focusNode: focusNode,
      cursorColor: Themes.black1,
      controller: textFieldController,
      style: Themes.TextFieldMainText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Themes.TextFieldHintText,
        prefixIcon: icon != null
            ? Icon(icon, color: Themes.black1)
            : null, // Show only if icon is not null
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 8.w),
      ),
      onChanged: onChanged,
    ),
  );
}
