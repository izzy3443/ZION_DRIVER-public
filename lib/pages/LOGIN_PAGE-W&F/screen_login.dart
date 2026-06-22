import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/TextFieldZero.dart';
import 'package:zion_driver_553/auth/firebase_auth.dart';
import 'package:zion_driver_553/paths.dart';
import 'package:zion_driver_553/theme.dart';

final AutoDisposeStateProvider<bool> isButtonLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();
  final AutoDisposeStateProvider<bool> isButtonEnabledProvider =
      StateProvider.autoDispose<bool>((ref) => false);

  @override
  void dispose() {
    phoneController.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Auto-focus the phone field when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(phoneFocusNode);
    });

    // Add listener to check phone number length and update button state
    phoneController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    ref
        .read(isButtonEnabledProvider.notifier)
        .update((state) => phoneController.text.length == 10);
  }

  void _onContinuePressed() async {
    if (ref.read(isButtonEnabledProvider)) {
      ref.read(isButtonLoadingProvider.notifier).update((state) => true);
      await ref
          .read(authProvider)
          .phoneSignIn(context, '+91${phoneController.text}', ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isButtonAccepted = ref.watch(isButtonEnabledProvider);
    return Scaffold(
      backgroundColor: Themes.white0,
      body: SafeArea(
        child: Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top flexible spacing
                const Spacer(flex: 2),

                // Header text
                Text("lets_get_started".tr(), style: Themes.headline3),

                SizedBox(height: 10.h),

                // Description text
                Text(
                  "sms_verification_note".tr(),
                  style: Themes.subtitlesubText,
                ),

                SizedBox(height: 12.h),

                // Phone input field using the existing textFieldZero widget
                textFieldZero(phoneController, "enter_your_mobile".tr(), 10,
                    focusNode: phoneFocusNode),

                // Push the button to the bottom
                const Spacer(flex: 3),

                // Continue Button with conditional styling
                customButton(
                    onPressed: () => _onContinuePressed(),
                    text: "continue".tr(),
                    backgroundColor:
                        isButtonAccepted ? Themes.fire_red : Colors.grey,
                    isLoading: ref.watch(isButtonLoadingProvider)),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
