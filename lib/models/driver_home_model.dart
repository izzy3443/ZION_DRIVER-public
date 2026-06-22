import 'package:geolocator/geolocator.dart';

enum DriverHomeEvent {
  none,
  notLoggedIn,
  userDocMissing,
  permissionRequired,
  subscriptionInactive,
  goToTrip,
  error,
}

class DriverHomeState {
  final Position? position;
  final bool isOnline;
  final bool isLoading;
  final String? activeTripId;

  const DriverHomeState({
    this.position,
    this.isOnline = false,
    this.isLoading = false,
    this.activeTripId,
  });

  DriverHomeState copyWith({
    Position? position,
    bool? isOnline,
    bool? isLoading,
    String? activeTripId,
  }) {
    return DriverHomeState(
      position: position ?? this.position,
      isOnline: isOnline ?? this.isOnline,
      isLoading: isLoading ?? this.isLoading,
      activeTripId: activeTripId ?? this.activeTripId,
    );
  }
}
