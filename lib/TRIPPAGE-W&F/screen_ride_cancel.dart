import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restart_app/restart_app.dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/models/trip_details_model.dart';
import 'package:zion_driver_553/theme.dart';
import 'package:zion_driver_553/providers/provider_user.dart';

class DriverCancelDialog extends ConsumerStatefulWidget {
  final TripDetailsModel tripDetailsModel;
  const DriverCancelDialog({
    super.key,
    required this.tripDetailsModel,
  });

  @override
  ConsumerState<DriverCancelDialog> createState() => _DriverCancelDialogState();
}

class _DriverCancelDialogState extends ConsumerState<DriverCancelDialog> {
  final TextEditingController _otherReasonController = TextEditingController();
  final selectedReasonProvider = StateProvider<String?>((ref) => null);
  final isLoadingProvider = StateProvider<bool>((ref) => false);

  final List<String> cancelReasons = [
    "customer_did_not_show_up".tr(),
    "vehicle_issue_or_breakdown".tr(),
    "wrong_pickup_location".tr(),
    "emergency_situation".tr(),
    "other".tr(),
  ];

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedReason = ref.watch(selectedReasonProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: Themes.white0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 48, color: Themes.fire_red),

              SizedBox(height: 16.h),
              Text(
                "cancel_this_ride".tr(),
                textAlign: TextAlign.center,
                style: Themes.headline2.copyWith(fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10.h),
              Text(
                "too_many_cancellations_warning".tr(),
                textAlign: TextAlign.center,
                style: Themes.subtitlesubText.copyWith(fontSize: 14.sp),
              ),

              SizedBox(height: 24.h),

              /// Reason options
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: cancelReasons.map((reason) {
                  final isSelected = selectedReason == reason;
                  return ChoiceChip(
                    label: Text(reason),
                    selected: isSelected,
                    onSelected: (_) => ref
                        .read(selectedReasonProvider.notifier)
                        .state = reason,
                    selectedColor: Themes.selected_red,
                    backgroundColor: Themes.white1,
                    labelStyle: const TextStyle(
                      color: Themes.black1,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),

              if (selectedReason == "Other".tr()) ...[
                SizedBox(height: 12.h),
                TextField(
                  controller: _otherReasonController,
                  decoration: InputDecoration(
                    hintText: "enter_reason".tr(),
                    filled: true,
                    fillColor: Themes.white1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                  ),
                  maxLines: 2,
                ),
              ],

              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Themes.gray2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        "go_back".tr(),
                        style: TextStyle(color: Themes.black1, fontSize: 16.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: customButton(
                      text: "confirm_cancel".tr(),
                      onPressed: selectedReason == null
                          ? null
                          : () async {
                              final reasonToUse = selectedReason == "Other"
                                  ? _otherReasonController.text.trim()
                                  : selectedReason;

                              if (reasonToUse.isEmpty) {
                                return;
                              }
                              await cancel_Ride(ref, reasonToUse, context);
                            },
                      isLoading: isLoading,
                      textStyle: Themes.buttonText
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> cancel_Ride(
    WidgetRef ref,
    String selectedReason,
    BuildContext context,
  ) async {
    ref.read(isLoadingProvider.notifier).state = true;

    try {
      final userId = widget.tripDetailsModel.UserId;
      final driverId = ref.read(userProvider)!.uid;
      final tripId = widget.tripDetailsModel.TripId;

      final callable = FirebaseFunctions.instance.httpsCallable('endTrip');

      final response = await callable.call({
        'tripId': tripId,
        'userId': userId,
        'driverId': driverId,
        'cancelReason': selectedReason,
        'cancelledBy': "driver",
      });

      final result = response.data;
      if (result['success'] == true) {
        ref.read(isLoadingProvider.notifier).state = false;
        Navigator.pop(context); // Close any open dialog/screen
        Restart.restartApp(); // Restart the app (fresh state)
      } else {
        throw Exception("Cancellation failed");
      }
    } on FirebaseFunctionsException catch (e) {
      Navigator.pop(context);
      ref.read(isLoadingProvider.notifier).state = false;
      showCustomSnackBar(context, "Something went wrong");
    } catch (e) {
      Navigator.pop(context);
      ref.read(isLoadingProvider.notifier).state = false;
      showCustomSnackBar(context, "Something went wrong");
    }
  }
}
