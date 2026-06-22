import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/TextFieldZero.dart';
import 'package:zion_driver_553/auth/firebase_auth.dart';
import 'package:zion_driver_553/theme.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpPage(
      {super.key, required this.phoneNumber, required this.verificationId});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

final AutoDisposeStateProvider<bool> isButtonLoadingOtpProvider =
    StateProvider.autoDispose<bool>((ref) => false);

class _OtpPageState extends ConsumerState<OtpPage> {
  TextEditingController otpController = TextEditingController();
  final AutoDisposeStateProvider<bool> isButtonEnabledProvider =
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
    ref.read(isButtonEnabledProvider.notifier).state =
        otpController.text.length == 6;
  }

  @override
  void dispose() {
    otpController.dispose();
    otpFocusNode.dispose();
    otpController.removeListener(_updateButtonState);
    super.dispose();
  }

  void onPressFunction() async {
    ref.read(isButtonLoadingOtpProvider.notifier).update((state) => true);
    ref.read(authProvider).onOtpPressedFunctions(
        context, widget.verificationId, otpController, ref);
  }

  @override
  Widget build(BuildContext context) {
    final isButtonActive = ref.watch(isButtonEnabledProvider);
    return Scaffold(
        backgroundColor: Themes.white0,
        body: SafeArea(
          child: Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  Text('almost_there'.tr(),
                      style: Themes.headline3.copyWith(fontSize: 27.sp)),
                  SizedBox(height: 10.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: 'enter_the_code_sent_to_your_number'.tr(),
                            style: Themes.subtitlesubText),
                        TextSpan(
                            text: widget.phoneNumber, style: Themes.subtitle),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  textFieldZero(otpController, 'enter_6_digit_otp'.tr(), 6,
                      focusNode: otpFocusNode),
                  const Spacer(flex: 3),
                  customButton(
                      onPressed: () {
                        isButtonActive ? onPressFunction() : null;
                      },
                      backgroundColor:
                          isButtonActive ? Themes.fire_red : Colors.grey,
                      text: "confirm".tr(),
                      isLoading: ref.watch(isButtonLoadingOtpProvider)),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ));
  }
}
