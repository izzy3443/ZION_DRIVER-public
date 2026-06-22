import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zion_driver_553/providers/provider_user.dart';
import 'package:zion_driver_553/TRIPPAGE-W&F/controller_trippage.dart';
import 'package:zion_driver_553/TRIPPAGE-W&F/screen_trippage.dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/Loading_UI.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/global_methods/loading.dart';

import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/models/trip_details_model.dart';
import 'package:zion_driver_553/paths.dart';
import 'package:zion_driver_553/theme.dart';

import 'package:zion_driver_553/var/global_var.dart';

Future<void> check_ava_of_trip_req(
    BuildContext context, WidgetRef ref, bool LoadingAvaiable) async {
  final tripDetails = ref.read(tripDetailsProvider);

  // Cancel timer when user takes action
  ShowLoadingDialog(context);

  try {
    if (ref.read(currentPositionProvider) == null) {
      final currentPosition = await Geolocator.getCurrentPosition();
      ref.read(currentPositionProvider.notifier).state = currentPosition;
    }

    final callable =
        FirebaseFunctions.instance.httpsCallable('assignDriverToTrip');

    final response = await callable.call({
      'tripId': tripDetails?.TripId,
      'userId': tripDetails?.UserId,
      'driverId': ref.read(userProvider)!.uid,
      'lat': ref.read(currentPositionProvider)!.latitude,
      'lng': ref.read(currentPositionProvider)!.longitude,
    });

    final result = response.data;
    if (result['success'] == true) {
      // ✅ Turn off location updates and remove from driver database

      // if (LoadingAvaiable) {
      //   ref.read(isLoadingProviderAccept.notifier).state = false;
      // }

      Navigator.pop(context); // Close dialog

      // Navigate to trip page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Newtrippage(isExistingTripStatus: false),
        ),
      );
    } else {
      throw Exception("Trip assignment failed");
    }
  } on FirebaseFunctionsException catch (e) {
    Navigator.pop(context);
    switch (e.code) {
      case "cancelled":
        showCustomSnackBar(context, "trip_request_cancelled_by_user".tr());
        break;
      case "timeout":
        showCustomSnackBar(context, "trip_request_timed_out".tr());
        break;
      case "failed-precondition":
        showCustomSnackBar(context, "trip_request_not_available".tr());
        break;
      default:
        showCustomSnackBar(context, "Error: ${e.message}");
    }
  } catch (e) {
    Navigator.pop(context);
    showCustomSnackBar(context, "an_unexpected_error_occurred".tr());
  }
}
