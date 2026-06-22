import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final markerSetNotifierProvider =
    StateNotifierProvider<MarkerStateNotifier, Set<Marker>>(
  (ref) => MarkerStateNotifier(),
);

class MarkerStateNotifier extends StateNotifier<Set<Marker>> {
  MarkerStateNotifier() : super({});

  void addMarker(Marker marker) {
    state = {...state, marker};
  }

  void clearMarkers() {
    state = {};
  }
}
