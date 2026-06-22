import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:zion_driver_553/UI/Loading_UI.dart';
import 'package:zion_driver_553/UI/smallUI.dart';
import 'package:zion_driver_553/theme.dart';

Widget modernDriverSwipeButton({
  required String text,
  required Future<void> Function() onSubmit,
  required Color outerColor,
  bool isLoading = false,
  Icon? icon,
}) {
  return SizedBox(
    height: 70.7.h,
    width: double.infinity,
    child: isLoading
        ? Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Themes.gray2,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: boxShadow(),
            ),
            child: SizedBox(
              width: 25.w,
              height: 25.h,
              child: LoadingCircle(false),
            ),
          )
        : SlideAction(
            text: text,
            onSubmit: onSubmit,
            outerColor: outerColor,
            innerColor: Themes.white0,
            borderRadius: 16.r,
            elevation: 4,
            sliderButtonIcon: icon ??
                const Icon(Icons.arrow_forward_ios, color: Themes.black0),
            sliderButtonIconSize: 18.7,
            sliderButtonIconPadding: 13.7,
            submittedIcon: null,
            textStyle: Themes.buttonText.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
  );
}
