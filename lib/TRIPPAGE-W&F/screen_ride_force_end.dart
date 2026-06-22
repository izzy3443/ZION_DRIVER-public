import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/Loading_UI.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/models/trip_details_model.dart';
import 'package:zion_driver_553/theme.dart';
import 'package:zion_driver_553/TRIPPAGE-W&F/screen_fare_collection.dart';

class DriverEarlyEndDialog extends ConsumerStatefulWidget {
  final String TripId;
  final String vehicleType;
  final double pickUpLat;
  final double pickUpLng;
  final double dropLat;
  final double dropLng;
  const DriverEarlyEndDialog({
    required this.TripId,
    required this.vehicleType,
    required this.pickUpLat,
    required this.pickUpLng,
    required this.dropLat,
    required this.dropLng,
    super.key,
  });

  @override
  ConsumerState<DriverEarlyEndDialog> createState() =>
      _DriverEarlyEndDialogState();
}

class _DriverEarlyEndDialogState extends ConsumerState<DriverEarlyEndDialog> {
  final TextEditingController _otherReasonController = TextEditingController();
  final selectedReasonProvider = StateProvider<String?>((ref) => null);
  final isLoadingProvider = StateProvider<bool>((ref) => false);

  final List<String> earlyEndReasons = [
    "customer_requested_end".tr(), // customer wanted to end
    "route_blocked".tr(), // road block or detour
    "emergency_stop".tr(), // emergency
    "vehicle_issue".tr(), // vehicle issue
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
                "end_trip_early".tr(),
                textAlign: TextAlign.center,
                style: Themes.headline2.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),

              Text(
                "ending_early_may_affect_fare"
                    .tr(), // Explain fare might change
                textAlign: TextAlign.center,
                style: Themes.subtitlesubText.copyWith(fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),

              /// Reason selection
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: earlyEndReasons.map((reason) {
                  final isSelected = selectedReason == reason;
                  return ChoiceChip(
                    label: Text(reason),
                    selected: isSelected,
                    onSelected: (_) => ref
                        .read(selectedReasonProvider.notifier)
                        .state = reason,
                    selectedColor: Themes.selected_red,
                    backgroundColor: Themes.white1,
                    labelStyle: TextStyle(
                      color: Themes.black1,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),

              /// Optional custom reason
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

              /// Buttons
              Row(
                children: [
                  /// Encourage not ending early
                  Expanded(
                    child: customButton(
                      text: "no_continue_trip".tr(), // Like "No, continue trip"
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Themes
                          .fire_red, // red to subtly discourage early ending
                      textStyle: Themes.buttonText
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  /// End anyway
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        if (selectedReason == null) {
                          showCustomSnackBar(
                              context, "please_select_reason".tr());
                          return;
                        }

                        final finalReason = selectedReason == "Other".tr()
                            ? _otherReasonController.text.trim()
                            : selectedReason;

                        if (finalReason.isEmpty) {
                          showCustomSnackBar(
                              context, "please_select_reason".tr());
                          return;
                        }

                        await endTripEarly(ref, finalReason, context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        side: BorderSide(color: Themes.gray2),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: LoadingCircle(false),
                            )
                          : Text(
                              "yes_end_anyway".tr(),
                              style: TextStyle(
                                  color: Themes.black1, fontSize: 16.sp),
                            ),
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

  Future<void> endTripEarly(
    WidgetRef ref,
    String reason,
    BuildContext context,
  ) async {
    ref.read(isLoadingProvider.notifier).state = true;

    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('endTrip');
      final response = await callable.call({
        "tripId": widget.TripId,
        "vehicleType": widget.vehicleType,
        "pickup": {
          "lat": widget.pickUpLat,
          "lng": widget.pickUpLng,
        },
        "dropoff": {
          "lat": widget.dropLat,
          "lng": widget.dropLng,
        },
        "forceEndTrip": true,
      });

      final result = response.data;
      if (result['status'] == 'success') {
        ref.read(isLoadingProvider.notifier).state = false;
        Navigator.pop(context);
        displayPaymentDialog(ref, result['fareAmount']);
      } else {
        throw Exception("Failed to end early");
      }
    } catch (e) {
      ref.read(isLoadingProvider.notifier).state = false;
      Navigator.pop(context);
      showCustomSnackBar(context, "Something went wrong");
    }
  }

  void displayPaymentDialog(WidgetRef ref, String fareAmount) {
    final tripRef =
        FirebaseFirestore.instance.collection("trip_req").doc(widget.TripId);
    Navigator.of(ref.context).push(
      MaterialPageRoute(
        builder: (context) => DriverFareCollectionPage(
          fare_amount: fareAmount,
          trip_req_ref: tripRef,
        ),
      ),
    );
  }
}
