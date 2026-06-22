import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/pages/HOME_PAGE-W&F/controller_dashboard.dart';

final googleMapControllerProvider =
    StateProvider<GoogleMapController?>((ref) => null);

class HomeMapView extends ConsumerWidget {
  const HomeMapView({super.key});

  static const _fallback = LatLng(9.7131, 76.6833);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(
      driverHomeControllerProvider.select((s) => s.position),
    );

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: position != null
            ? LatLng(position.latitude, position.longitude)
            : _fallback,
        zoom: 15,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      onMapCreated: (controller) {
        ref.read(googleMapControllerProvider.notifier).state = controller;
      },
    );
  }
}
