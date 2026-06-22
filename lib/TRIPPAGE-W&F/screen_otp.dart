import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/TextFieldZero.dart';
import 'package:zion_driver_553/theme.dart';
import 'package:zion_driver_553/var/global_var.dart';

class DriverStartOtpPage extends ConsumerStatefulWidget {
  final String otp;
  const DriverStartOtpPage({
    required this.otp,
    super.key,
  });

  @override
  ConsumerState<DriverStartOtpPage> createState() => _DriverStartOtpPageState();
}

class _DriverStartOtpPageState extends ConsumerState<DriverStartOtpPage> {
  final AutoDisposeStateProvider<bool> isDriverOtpButtonLoadingProvider =
      StateProvider.autoDispose<bool>((ref) => false);
  final TextEditingController otpController = TextEditingController();
  final AutoDisposeStateProvider<bool> isDriverOtpButtonEnabledProvider =
      StateProvider.autoDispose<bool>((ref) => false);
  final FocusNode otpFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(otpFocusNode);
    });
    otpController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    ref.read(isDriverOtpButtonEnabledProvider.notifier).state =
        otpController.text.length == 4;
  }

  @override
  void dispose() {
    otpController.dispose();
    otpFocusNode.dispose();
    otpController.removeListener(_updateButtonState);
    super.dispose();
  }

  void onConfirmOtp() async {
    ref.read(isDriverOtpButtonLoadingProvider.notifier).state = true;

    if (otpController.text.trim() == widget.otp) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("incorrect_otp_please_try_again".tr())),
      );
    }

    ref.read(isDriverOtpButtonLoadingProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final isButtonActive = ref.watch(isDriverOtpButtonEnabledProvider);
    final isLoading = ref.watch(isDriverOtpButtonLoadingProvider);

    return Scaffold(
      backgroundColor: Themes.white0,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Text("start_ride".tr(),
                  style: Themes.headline3.copyWith(fontSize: 27.sp)),
              SizedBox(height: 10.h),
              Text(
                'ask_rider_for_otp'.tr(),
                style: Themes.subtitlesubText,
              ),
              SizedBox(height: 12.h),
              textFieldZero(
                otpController,
                'enter_4_digit_otp'.tr(),
                4,
                focusNode: otpFocusNode,
              ),
              const Spacer(flex: 3),
              customButton(
                text: "start_ride".tr(),
                isLoading: isLoading,
                onPressed: isButtonActive ? onConfirmOtp : null,
                backgroundColor: isButtonActive ? Themes.fire_red : Colors.grey,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
