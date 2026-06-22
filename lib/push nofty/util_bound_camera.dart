import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLngBounds boundCameraUpdate(
  double pickupLat,
  double pickupLng,
  double dropOffLat,
  double dropOffLng,
) {
  final LatLng pickupGeo = LatLng(pickupLat, pickupLng);
  final LatLng destGeo = LatLng(dropOffLat, dropOffLng);

  LatLngBounds boundsLatLng;
  if (pickupGeo.latitude > destGeo.latitude &&
      pickupGeo.longitude > destGeo.longitude) {
    boundsLatLng = LatLngBounds(southwest: destGeo, northeast: pickupGeo);
  } else if (pickupGeo.longitude > destGeo.longitude) {
    boundsLatLng = LatLngBounds(
      southwest: LatLng(pickupGeo.latitude, destGeo.longitude),
      northeast: LatLng(destGeo.latitude, pickupGeo.longitude),
    );
  } else if (pickupGeo.latitude > destGeo.latitude) {
    boundsLatLng = LatLngBounds(
      southwest: LatLng(destGeo.latitude, pickupGeo.longitude),
      northeast: LatLng(pickupGeo.latitude, destGeo.longitude),
    );
  } else {
    boundsLatLng = LatLngBounds(
      southwest: pickupGeo,
      northeast: destGeo,
    );
  }
  return boundsLatLng;
}
