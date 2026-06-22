class PermissionState {
  final bool drawOverApps;
  final bool autoStart;
  final bool batteryOptimization;
  final bool notifications;
  final bool location;
  final bool isLoading;

  const PermissionState({
    this.drawOverApps = false,
    this.autoStart = false,
    this.batteryOptimization = false,
    this.notifications = false,
    this.location = false,
    this.isLoading = false,
  });

  PermissionState copyWith({
    bool? drawOverApps,
    bool? autoStart,
    bool? batteryOptimization,
    bool? notifications,
    bool? location,
    bool? isLoading,
  }) {
    return PermissionState(
      drawOverApps: drawOverApps ?? this.drawOverApps,
      autoStart: autoStart ?? this.autoStart,
      batteryOptimization: batteryOptimization ?? this.batteryOptimization,
      notifications: notifications ?? this.notifications,
      location: location ?? this.location,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
