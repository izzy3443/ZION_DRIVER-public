import 'package:flutter/material.dart';
import 'package:zion_driver_553/theme.dart';

Widget textFieldZero(
  TextEditingController textFieldController,
  String hintText,
  int maxlength, {
  FocusNode? focusNode,
}) {
  return TextField(
      maxLength: 10,
      controller: textFieldController,
      focusNode: focusNode,
      keyboardType: TextInputType.phone,
      cursorColor: Themes.gray2,
      cursorWidth: 2.5,
      decoration: InputDecoration(
        counterText: "",
        hintText: hintText,
        hintStyle: Themes.TextFieldPlaceHolder,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: Themes.TextFieldText);
}
