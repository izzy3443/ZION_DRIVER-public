import 'dart:io';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_intent_plus/android_intent.dart';

import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zion_driver_553/models/permission_model.dart';

import 'package:zion_driver_553/pages/PERMISSION-W&F/controller_permission_check.dart';
import 'package:zion_driver_553/pages/PERMISSION-W&F/screen_permission_instructions.dart';

final permissionsProvider =
    StateNotifierProvider<PermissionsNotifier, PermissionState>(
  (ref) => PermissionsNotifier(),
);

class PermissionsNotifier extends StateNotifier<PermissionState> {
  PermissionsNotifier() : super(const PermissionState()) {
    checkAllPermissions();
  }

  Future<void> checkAllPermissions() async {
    state = state.copyWith(isLoading: true);

    try {
      final drawOverApps = await Permission.systemAlertWindow.isGranted;
      final notifications = await Permission.notification.isGranted;
      final batteryOptimization = await checkBatteryOptimization();
      final autoStart = await checkAutoStart();
      final location = await Permission.locationWhenInUse.isGranted;

      state = PermissionState(
        drawOverApps: drawOverApps,
        autoStart: autoStart,
        batteryOptimization: batteryOptimization,
        notifications: notifications,
        location: location,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> requestBatteryOptimization() async {
    if (Platform.isAndroid) {
      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      } else if (await Permission
          .ignoreBatteryOptimizations.isPermanentlyDenied) {
        await openAppSettings();
      }
    }
    await checkAllPermissions();
  }

  Future<void> requestDrawOverApps() async {
    if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    } else if (await Permission.systemAlertWindow.isPermanentlyDenied) {
      await openAppSettings();
    }
    await checkAllPermissions();
  }

  Future<void> requestAutoStart() async {
    if (Platform.isAndroid) {
      await openAppSettings();
    }
    await checkAllPermissions();
  }

  Future<void> requestNotifications(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PermissionInstructionsPage(
          permissionName: 'notifications'.tr(),
          icon: Icons.notifications_active,
          emoji: '🔔',
        ),
      ),
    );
    await checkAllPermissions();
  }

  Future<void> requestLocation(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PermissionInstructionsPage(
          permissionName: 'Location',
          icon: Icons.location_on,
          emoji: '📍',
        ),
      ),
    );

    await checkAllPermissions();
  }
}

Future<void> requestOverlayPermission() async {
  const channel = MethodChannel("overlay_permission_channel");

  final hasPermission = await channel.invokeMethod<bool>("checkPermission");
  if (hasPermission == true) {
    debugPrint("✅ Overlay permission already granted");
    return;
  }

  final intent = AndroidIntent(
    action: 'android.settings.action.MANAGE_OVERLAY_PERMISSION',
    data:
        'package:com.example.zion_driver_553', // replace with your actual package
  );

  await intent.launch();
}

// grant_permissions_page.dart
