import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restart_app/restart_app.dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/auth/error_firebase.dart';

import 'package:zion_driver_553/pages/HOME_PAGE-W&F/screen_dashboard.dart';
import 'package:zion_driver_553/theme.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restart_app/restart_app.dart';
import 'package:easy_localization/easy_localization.dart';

class DriverFareCollectionPage extends ConsumerWidget {
  final String fare_amount;
  final DocumentReference trip_req_ref;
  DriverFareCollectionPage({
    super.key,
    required this.fare_amount,
    required this.trip_req_ref,
  });
  final StateProvider<bool> fareCollectLoadingProvider =
      StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(fareCollectLoadingProvider);

    return Scaffold(
      backgroundColor: Themes.white0,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              Text(
                "trip_completed".tr(),
                style: Themes.headline2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "collect_fare_amount".tr(),
                style: Themes.headline3.copyWith(
                  color: Themes.gray2,
                ),
              ),
              SizedBox(height: 40.h),
              Text(
                "total_fare".tr(),
                style: Themes.subtitlesubText.copyWith(fontSize: 16.sp),
              ),
              SizedBox(height: 10.h),
              Text(
                "₹$fare_amount",
                style: Themes.headline2.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32.sp,
                ),
              ),
              SizedBox(height: 40.h),
              customButton(
                text: "collected".tr(),
                isLoading: isLoading,
                onPressed: () => onCollected(context, ref),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  void onCollected(BuildContext context, WidgetRef ref) async {
    try {
      ref.read(fareCollectLoadingProvider.notifier).state = true;

      // turnoff_location_updates_homepage_remove_driver_database(ref);

      print(
          "BELOW ARE ALL THE DETAILS THAT ARE SUPPOSE TO BE NOT NULL BEFORE TRIP END");

      await trip_req_ref.update({"Status": "Paid"});

      ref.read(fareCollectLoadingProvider.notifier).state = false;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DriverHomePage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ref.read(fareCollectLoadingProvider.notifier).state = false;
      handleFirestoreException(context, e);
    }
  }
}
