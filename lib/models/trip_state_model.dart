import 'package:geolocator/geolocator.dart';

class TripState {
  final Position? position;
  final String status; // accepted, arrived, picked_up, ended
  final bool isLoading;
  final bool isFirstRoute;
  final bool moreOptionsEnabled;

  const TripState({
    this.position,
    required this.status,
    this.isLoading = false,
    this.isFirstRoute = true,
    this.moreOptionsEnabled = true,
  });

  TripState copyWith({
    Position? position,
    String? status,
    bool? isLoading,
    bool? isFirstRoute,
    bool? moreOptionsEnabled,
  }) {
    return TripState(
      position: position ?? this.position,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isFirstRoute: isFirstRoute ?? this.isFirstRoute,
      moreOptionsEnabled: moreOptionsEnabled ?? this.moreOptionsEnabled,
    );
  }
}

enum TripEvent {
  none,
  tripCancelled,
  showPayment,
  forceEndRequired,
  error,
  tripEnded,
  arrivedSuccess,
  pickupSuccess,
  otpFailed,
  overLimit,
}
