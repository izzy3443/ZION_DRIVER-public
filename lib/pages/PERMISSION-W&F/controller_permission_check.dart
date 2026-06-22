import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

Future<bool> areAllPermissionsGranted() async {
  final drawOverApps = await Permission.systemAlertWindow.isGranted;
  final notifications = await Permission.notification.isGranted;
  final batteryOptimization = await checkBatteryOptimization();
  final autoStart = await checkAutoStart();
  final location = await Permission.locationWhenInUse.isGranted;

  return drawOverApps &&
      notifications &&
      batteryOptimization &&
      autoStart &&
      location;
}

Future<bool> checkBatteryOptimization() async {
  if (Platform.isAndroid) {
    return await Permission.ignoreBatteryOptimizations.isGranted;
  }
  return true;
}

Future<bool> checkAutoStart() async {
  if (Platform.isAndroid) {
    return true;
  }
  return true;
}
