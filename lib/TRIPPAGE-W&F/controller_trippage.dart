import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zion_driver_553/models/trip_state_model.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/global_methods/loading.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/models/trip_details_model.dart';
import 'package:zion_driver_553/pages/HOME_PAGE-W&F/screen_HomeMap.dart';
import 'package:zion_driver_553/pages/HOME_PAGE-W&F/screen_dashboard.dart';
import 'package:zion_driver_553/paths.dart';
import 'package:zion_driver_553/providers/provider_marker.dart';
import 'package:zion_driver_553/push%20nofty/util_bound_camera.dart';
import 'package:zion_driver_553/TRIPPAGE-W&F/screen_fare_collection.dart';
import 'package:zion_driver_553/TRIPPAGE-W&F/screen_ride_force_end.dart';
import 'package:zion_driver_553/providers/provider_user.dart';
import 'package:zion_driver_553/var/global_var.dart';

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final currentPositionProvider = StateProvider<Position?>((ref) => null);

final tripControllerProvider =
    StateNotifierProvider.autoDispose<TripController, TripState>(
  (ref) => TripController(ref),
);

class TripController extends StateNotifier<TripState> {
  TripController(this.ref) : super(const TripState(status: 'new'));

  final Ref ref;

  StreamSubscription<Position>? _locationSub;
  StreamSubscription<DocumentSnapshot>? _tripSub;

  // ─────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────

  Future<void> initTrip(TripDetailsModel trip) async {
    await _getInstantLocation();
    _startLocationStream(trip.TripId);
    _listenToTripStatus(trip.TripId);

    final pos = state.position;
    if (pos != null) {
      await showDestinationPinAndZoom(
        pickup: LatLng(pos.latitude, pos.longitude),
        destination: trip.PickUpLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // LOCATION
  // ─────────────────────────────────────────────
  Future<void> _getInstantLocation() async {
    // here using map controller we need to move the camera accordingly cause i think we will use same map for two pages but using teh controller we can move  to the place accordlgly
    final pos = await Geolocator.getCurrentPosition();
    state = state.copyWith(position: pos);
  }

  void _startLocationStream(String tripId) {
    _locationSub?.cancel();

    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) async {
      state = state.copyWith(position: pos);

      await FirebaseFirestore.instance
          .collection("trip_req")
          .doc(tripId)
          .update({
        "DriverLocation": {
          "latitude": pos.latitude,
          "longitude": pos.longitude,
        }
      });
    });
  }

  // ─────────────────────────────────────────────
  // TRIP STATUS LISTENER
  // ─────────────────────────────────────────────
  void _listenToTripStatus(String tripId) {
    _tripSub?.cancel();

    String? lastStatus; // Track last status

    _tripSub = FirebaseFirestore.instance
        .collection("trip_req")
        .doc(tripId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      final status = doc['Status'] as String;

      // Only update if status actually changed
      if (status != lastStatus) {
        lastStatus = status;
        state = state.copyWith(status: status);
      }
    });
  }

  // ─────────────────────────────────────────────
  // ARRIVED
  // ─────────────────────────────────────────────

  Future<TripEvent> markArrived(TripDetailsModel trip) async {
    try {
      state = state.copyWith(isLoading: true);

      final pos = state.position!;
      final user = ref.read(userProvider)!;

      final res = await FirebaseFunctions.instance
          .httpsCallable("handleDriverArrived")
          .call({
        "tripId": trip.TripId,
        "userId": trip.UserId,
        "vehicleNumber": user.vehicleNumberPlate,
        "vehicleModel": user.vehicleDetails,
        "otp": trip.Otp,
        "driverLocation": {
          "lat": pos.latitude,
          "lng": pos.longitude,
        },
        "pickupLocation": {
          "lat": trip.PickUpLatLng.latitude,
          "lng": trip.PickUpLatLng.longitude,
        },
      });

      state = state.copyWith(isLoading: false);

      if (res.data["status"] == "success") {
        state = state.copyWith(status: "arrived");
        return TripEvent.arrivedSuccess;
      }

      if (res.data["status"] == "overlimit") {
        return TripEvent.overLimit;
      }

      return TripEvent.error;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return TripEvent.error;
    }
  }

  // ─────────────────────────────────────────────
  // PICKUP
  // ─────────────────────────────────────────────
  Future<TripEvent> markPickedUp(TripDetailsModel trip) async {
    try {
      // 1️⃣ Enter loading
      state = state.copyWith(isLoading: true);

      // 2️⃣ Call backend
      final res = await FirebaseFunctions.instance
          .httpsCallable("handleTripPickup")
          .call({
        "tripId": trip.TripId,
      });

      // 3️⃣ Validate response
      if (res.data["status"] != "success") {
        state = state.copyWith(isLoading: false);
        return TripEvent.error;
      }

      // 4️⃣ Update state FIRST (single source of truth)
      state = state.copyWith(
        isLoading: false,
        status: "picked_up",
        isFirstRoute: false,
        moreOptionsEnabled: false,
      );

      // 5️⃣ Camera + marker side-effect
      final pos = state.position;
      if (pos != null) {
        await showDestinationPinAndZoom(
          pickup: LatLng(pos.latitude, pos.longitude),
          destination: trip.DropOffLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        );
      }

      // 6️⃣ Emit event
      return TripEvent.pickupSuccess;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return TripEvent.error;
    }
  }

  // ─────────────────────────────────────────────
  // END TRIP
  // ─────────────────────────────────────────────
  Future<TripEvent> endTrip(TripDetailsModel trip) async {
    try {
      state = state.copyWith(isLoading: true);

      final pos = state.position!;
      final user = ref.read(userProvider)!;

      final callable = FirebaseFunctions.instance.httpsCallable('endTrip');

      final res = await callable.call({
        "tripId": trip.TripId,
        "vehicleType": user.vehicleType,
        "pickup": {
          "lat": pos.latitude,
          "lng": pos.longitude,
        },
        "dropoff": {
          "lat": trip.DropOffLatLng.latitude,
          "lng": trip.DropOffLatLng.longitude,
        },
        "forceEndTrip": false,
      });

      state = state.copyWith(isLoading: false);

      if (res.data['status'] == 'success') {
        final result = res.data;
        ref
            .read(tripDetailsProvider.notifier)
            .updateFareAmount(result['fareAmount']);
        return TripEvent.showPayment;
      }

      if (res.data['status'] == 'overlimit') {
        return TripEvent.forceEndRequired;
      }

      return TripEvent.error;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return TripEvent.error;
    }
  }

  Future<void> showDestinationPinAndZoom({
    required LatLng pickup,
    required LatLng destination,
    required BitmapDescriptor icon,
  }) async {
    // 1️⃣ Add destination marker
    final marker = Marker(
      markerId: const MarkerId("destination"),
      position: destination,
      icon: icon,
    );

    ref.read(markerSetNotifierProvider.notifier).clearMarkers();
    ref.read(markerSetNotifierProvider.notifier).addMarker(marker);

    // 2️⃣ Animate camera bounds
    final mapController = ref.read(googleMapControllerProvider);
    if (mapController == null) return;

    final bounds = boundCameraUpdate(
      pickup.latitude,
      pickup.longitude,
      destination.latitude,
      destination.longitude,
    );

    await mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 72),
    );
  }

  // ─────────────────────────────────────────────
  // EVENTS
  // ─────────────────────────────────────────────
  final _eventController = StreamController<TripEvent>.broadcast();
  Stream<TripEvent> get events => _eventController.stream;

  // ─────────────────────────────────────────────
  // CLEANUP
  // ─────────────────────────────────────────────
  @override
  void dispose() {
    _locationSub?.cancel();
    _tripSub?.cancel();
    _eventController.close();
    super.dispose();
  }
}
