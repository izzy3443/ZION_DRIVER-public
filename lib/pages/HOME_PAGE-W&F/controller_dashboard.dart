import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/models/driver_home_model.dart';
import 'package:zion_driver_553/models/trip_details_model.dart';
import 'package:zion_driver_553/models/user_model.dart';

import 'package:zion_driver_553/pages/HOME_PAGE-W&F/screen_HomeMap.dart';
import 'package:zion_driver_553/push%20nofty/push_notify_system.dart';
import 'package:zion_driver_553/var/global_var.dart';
import 'package:zion_driver_553/providers/provider_user.dart';

final driverHomeControllerProvider =
    AutoDisposeNotifierProvider<DriverHomeController, DriverHomeState>(
  DriverHomeController.new,
);

class DriverHomeController extends AutoDisposeNotifier<DriverHomeState> {
  StreamSubscription<Position>? _locationSub;

  // ----------------------------------------------------
  // BUILD
  // ----------------------------------------------------
  @override
  DriverHomeState build() {
    ref.onDispose(_dispose);
    return const DriverHomeState();
  }

  // ----------------------------------------------------
  // INIT (CALLED FROM UI)
  // ----------------------------------------------------
  Future<DriverHomeEvent> init() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return DriverHomeEvent.notLoggedIn;
    }
    _initPushNotifications();
    final driverEvent = await _loadDriver(uid);
    if (driverEvent != DriverHomeEvent.none) {
      return driverEvent;
    }

    final locationEvent = await _loadInitialLocation();
    return locationEvent;
  }

  Future<void> _initPushNotifications() async {
    final pushSystem = PushNotifySystem();
    await pushSystem.generateNotificationToken();
  }

  // ---------------------------------
  // DRIVER LOAD
  // ---------------------------------
  Future<DriverHomeEvent> _loadDriver(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection("drivers").doc(uid).get();

    if (!doc.exists) {
      await FirebaseAuth.instance.signOut();
      return DriverHomeEvent.userDocMissing;
    }

    final rawUser = AppUser.fromMap(doc.data()!);
    final syncedUser = await _syncDailyStatsIfStale(rawUser, doc);
    final finalUser = await _checkSubscription(syncedUser, uid);
    final data = doc.data() as Map<String, dynamic>;

    ref.read(userProvider.notifier).setUser(finalUser);

    state = state.copyWith(
      isOnline: data['isOnline'] as bool? ?? false,
      activeTripId: finalUser.status != null && finalUser.status != "NONE"
          ? finalUser.status
          : null,
    );

    if (state.isOnline) {
      _startLocationStream();
    }

    if (state.activeTripId != null) {
      return await loadActiveTrip(finalUser.status!);
    }

    return DriverHomeEvent.none;
  }

  Future<DriverHomeEvent> loadActiveTrip(String tripId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("trip_req")
          .doc(tripId)
          .get();

      if (!doc.exists) {
        return DriverHomeEvent.none;
      }

      final data = doc.data() as Map<String, dynamic>;
      final tripModel = TripDetailsModel.fromMap(data);

      // 🔥 Store trip globally
      ref.read(tripDetailsProvider.notifier).setTrip(tripModel);

      // 🔥 Update local state if needed
      state = state.copyWith(
        activeTripId: tripId,
      );

      return DriverHomeEvent.goToTrip;
    } catch (e) {
      return DriverHomeEvent.error;
    }
  }

  // ----------------------------------------------------
  // LOCATION
  // ----------------------------------------------------
  Future<DriverHomeEvent> _loadInitialLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      state = state.copyWith(position: pos);
      return DriverHomeEvent.none;
    } catch (_) {
      return DriverHomeEvent.permissionRequired;
    }
  }

  void _startLocationStream() {
    _locationSub?.cancel();

    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      state = state.copyWith(position: pos);
      _animateToNewPosition(pos);
      _updateLocationInDb(pos);
    });
  }

  void _animateToNewPosition(Position position) {
    ref.read(googleMapControllerProvider)?.animateCamera(
          CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
        );
  }

  Future<void> _stopLocationStream() async {
    await _locationSub?.cancel();
    _locationSub = null;
  }

  // ------------------
  // ONLINE / OFFLINE
  // ------------------
  Future<DriverHomeEvent> toggleOnline() async {
    final user = ref.read(userProvider);
    if (user == null) {
      return DriverHomeEvent.notLoggedIn;
    }

    state = state.copyWith(isLoading: true);

    try {
      if (!state.isOnline) {
        if (!(user.isVerified ?? false)) {
          return DriverHomeEvent.permissionRequired;
        }

        if (!(user.subscriptionActive ?? false)) {
          return DriverHomeEvent.subscriptionInactive;
        }
        await _goOnline(user);
        _startLocationStream();
        state = state.copyWith(isOnline: true);
      } else {
        await _goOffline(user);
        state = state.copyWith(isOnline: false);
      }

      return DriverHomeEvent.none;
    } catch (_) {
      return DriverHomeEvent.error;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _goOnline(AppUser user) async {
    final pos = state.position;
    if (pos == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final path = convo_online_driver_ref[user.vehicleType]!;

    final geo = GeoFirePoint(GeoPoint(pos.latitude, pos.longitude));

    await FirebaseFirestore.instance.runTransaction((tx) async {
      tx.update(
        FirebaseFirestore.instance.collection("drivers").doc(uid),
        {'isOnline': true},
      );
      tx.set(
        FirebaseFirestore.instance.collection(path).doc(uid),
        {'geo': geo.data, 'lastUpdated': FieldValue.serverTimestamp()},
      );
    });
  }

  Future<void> _goOffline(AppUser user) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final path = convo_online_driver_ref[user.vehicleType]!;

    await FirebaseFirestore.instance.runTransaction((tx) async {
      tx.update(
        FirebaseFirestore.instance.collection("drivers").doc(uid),
        {'isOnline': false},
      );
      tx.delete(
        FirebaseFirestore.instance.collection(path).doc(uid),
      );
    });

    await _stopLocationStream();
  }

  // ----------------------------------------------------
  // HELPERS
  // ----------------------------------------------------
  void _updateLocationInDb(Position pos) {
    final user = ref.read(userProvider);
    if (user == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final path = convo_online_driver_ref[user.vehicleType]!;

    final geo = GeoFirePoint(GeoPoint(pos.latitude, pos.longitude));

    FirebaseFirestore.instance.collection(path).doc(uid).set({
      'geo': geo.data,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<AppUser> _checkSubscription(AppUser user, String uid) async {
    try {
      final res = await FirebaseFunctions.instance
          .httpsCallable("checkSubscription")
          .call({'uid': uid});

      return user.copyWith(
        subscriptionActive: res.data['active'] ?? false,
        subscriptionExpiry: DateTime.tryParse(res.data['expiry'] ?? ""),
      );
    } catch (_) {
      return user.copyWith(subscriptionActive: false);
    }
  }

  Future<AppUser> _syncDailyStatsIfStale(
    AppUser user,
    DocumentSnapshot doc,
  ) async {
    final data = doc.data() as Map<String, dynamic>;
    final last = (data['totalUpdatedTime'] as Timestamp?)?.toDate();
    final now = DateTime.now();

    if (last == null ||
        DateTime(last.year, last.month, last.day) !=
            DateTime(now.year, now.month, now.day)) {
      await doc.reference.update({
        'ridesToday': 0,
        'earningsToday': 0,
        'totalUpdatedTime': Timestamp.now(),
      });

      return user.copyWith(ridesToday: 0, earningsToday: 0);
    }

    return user;
  }

  void _dispose() {
    print(
        "HEYEYEYEYEYEYEYEYE WIDGET DISPOSING MEANING LIKE LOCATION STREM STOP AND MAPS GONE AND LIKE STATE LIKKED NICEEE THING");
    _locationSub?.cancel();
  }
}
