import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final tripDetailsProvider =
    StateNotifierProvider<TripDetailsNotifier, TripDetailsModel?>(
  (ref) => TripDetailsNotifier(),
);

class TripDetailsModel {
  final String TripId;

  /// 🔥 NEW
  final String Status; // new | accepted | arrived | picked_up | completed

  final LatLng PickUpLatLng;
  final String PickUpAddress;

  final LatLng DropOffLatLng;
  final String DropOffAddress;

  final String FareAmount;
  final String Otp;
  final String UserId;

  // Enriched later
  final String? UserName;
  final String? UserPhone;
  final String? UserDeviceToken;

  const TripDetailsModel({
    required this.TripId,
    required this.Status,
    required this.PickUpLatLng,
    required this.PickUpAddress,
    required this.DropOffLatLng,
    required this.DropOffAddress,
    required this.FareAmount,
    required this.Otp,
    required this.UserId,
    this.UserName,
    this.UserPhone,
    this.UserDeviceToken,
  });

  /// ✅ Firestore → Model
  factory TripDetailsModel.fromMap(Map<String, dynamic> data) {
    return TripDetailsModel(
      TripId: data['TripId'],
      Status: data['Status'], // 🔒 safe default

      PickUpLatLng: LatLng(
        data['pickup_latlng']['latitude'],
        data['pickup_latlng']['longitude'],
      ),
      PickUpAddress: data['pickup_address'],

      DropOffLatLng: LatLng(
        data['dropoff_latlng']['latitude'],
        data['dropoff_latlng']['longitude'],
      ),
      DropOffAddress: data['dropoff_address'],

      FareAmount: data['FareAmount'],
      Otp: data['Otp'],
      UserId: data['UserId'],

      // user info enriched later
      UserName: null,
      UserPhone: null,
      UserDeviceToken: null,
    );
  }

  /// ✅ CopyWith (used for enrichment + status updates)
  TripDetailsModel copyWith({
    String? Status,
    String? FareAmount,
    String? UserName,
    String? UserPhone,
    String? UserDeviceToken,
  }) {
    return TripDetailsModel(
      TripId: TripId,
      Status: Status ?? this.Status,
      PickUpLatLng: PickUpLatLng,
      PickUpAddress: PickUpAddress,
      DropOffLatLng: DropOffLatLng,
      DropOffAddress: DropOffAddress,
      FareAmount: FareAmount ?? this.FareAmount, // 👈 HERE
      Otp: Otp,
      UserId: UserId,
      UserName: UserName ?? this.UserName,
      UserPhone: UserPhone ?? this.UserPhone,
      UserDeviceToken: UserDeviceToken ?? this.UserDeviceToken,
    );
  }

  /// Optional: serialize (if ever needed)
  Map<String, dynamic> toMap() {
    return {
      'TripId': TripId,
      'Status': Status,
      'pickup_latlng': {
        'latitude': PickUpLatLng.latitude,
        'longitude': PickUpLatLng.longitude,
      },
      'pickup_address': PickUpAddress,
      'dropoff_latlng': {
        'latitude': DropOffLatLng.latitude,
        'longitude': DropOffLatLng.longitude,
      },
      'dropoff_address': DropOffAddress,
      'FareAmount': FareAmount,
      'Otp': Otp,
      'UserId': UserId,
      if (UserName != null) 'UserName': UserName,
      if (UserPhone != null) 'UserPhone': UserPhone,
      if (UserDeviceToken != null) 'UserDeviceToken': UserDeviceToken,
    };
  }
}

class TripDetailsNotifier extends StateNotifier<TripDetailsModel?> {
  TripDetailsNotifier() : super(null);

  void setTrip(TripDetailsModel trip) {
    state = trip;
  }

  /// 🔥 Update only status
  void updateStatus(String status) {
    if (state == null) return;
    state = state!.copyWith(Status: status);
  }

  /// 🔥 Enrich with user info
  void enrichWithUserInfo(Map<String, dynamic> userData) {
    if (state == null) return;

    state = state!.copyWith(
      UserName:
          "${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}".trim(),
      UserPhone: userData['PhoneNo'],
      UserDeviceToken: userData['deviceToken'],
    );
  }

  void updateFareAmount(String fare) {
    if (state == null) return;

    state = state!.copyWith(FareAmount: fare);
  }

  void clear() {
    state = null;
  }
}
