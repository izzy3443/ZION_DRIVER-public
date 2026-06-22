import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

bool Location_permission_Status = false;

Future<void> requestLocationPermission() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever ||
      permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    // if denyed forever then the pop up will never show up
    if (permission == LocationPermission.denied) {
      Location_permission_Status = false;

      return;
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Location_permission_Status = true;

      return;
    }
  } else if (permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse) {
    Location_permission_Status = true;

    return;
  }
}
