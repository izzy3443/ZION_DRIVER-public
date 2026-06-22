import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion_driver_553/UI/Loading_UI.dart';
import 'package:zion_driver_553/models/trip_details_model.dart';
import 'package:zion_driver_553/pages/TRIP_REQ-W&F/B-notification_dialog.dart';

String? pendingTripId;
String? pendingMethod;
bool isTripBackgroundDone = false;

final MethodChannel tripChannel = MethodChannel('trip_channel');

void setupTripChannel() {
  tripChannel.setMethodCallHandler((MethodCall call) async {
    String method = call.method;
    String? tripId = call.arguments;
    pendingMethod = call.method;
    pendingTripId = call.arguments;
    isTripBackgroundDone = false;
  });
}

Future<void> checkAndHandlePendingTrip(
    BuildContext context, WidgetRef ref) async {
  if (!isTripBackgroundDone && pendingTripId != null && pendingMethod != null) {
    isTripBackgroundDone = true; // prevent double handling

    if (pendingMethod == 'tripAccepted') {
      await handleAcceptTrip(context, ref, pendingTripId!);
    }
  }
}

handleAcceptTrip(context, ref, tripId) async {
  DocumentSnapshot docSnapshot =
      await FirebaseFirestore.instance.collection("trip_req").doc(tripId).get();
  if (docSnapshot.exists) {
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    TripDetailsModel tripModel = TripDetailsModel.fromMap(data);

    ref.read(tripDetailsProvider.notifier).setTrip(tripModel);
  }
  await check_ava_of_trip_req(context, ref, false);
}
