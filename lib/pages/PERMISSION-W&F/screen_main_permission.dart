import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/UI/AppBar(ZION).dart';
import 'package:zion_driver_553/UI/Permission_Item.dart';

import 'package:zion_driver_553/pages/PERMISSION-W&F/controller_main_permission.dart';
import 'package:zion_driver_553/theme.dart';

class GrantPermissionsPage extends ConsumerWidget {
  const GrantPermissionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(permissionsProvider);
    final permissionsNotifier = ref.read(permissionsProvider.notifier);

    return Scaffold(
      backgroundColor: Themes.white0,
      appBar: CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await permissionsNotifier.checkAllPermissions();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.w),
              child: Text(
                "permissions".tr(),
                style: Themes.headline3
                    .copyWith(height: 0.0.h, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 14.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.r),
                children: [
                  SizedBox(height: 20.h),

                  // Draw over applications
                  buildStepItem(
                    icon: Icons.layers,
                    title: 'draw_over_applications'.tr(),
                    status: permissionState.drawOverApps
                        ? "granted".tr()
                        : "not_granted".tr(),
                    iconColor: const Color(0xFF4285F4),
                    textColor: permissionState.drawOverApps
                        ? Colors.green
                        : Colors.red,
                    onTap: permissionState.drawOverApps
                        ? () {}
                        : () => permissionsNotifier.requestDrawOverApps(),
                  ),

                  SizedBox(height: 16.h),

                  // Autostart
                  buildStepItem(
                    icon: Icons.bolt,
                    title: 'autostart_in_background'.tr(),
                    status: permissionState.autoStart
                        ? "granted".tr()
                        : "not_granted".tr(),
                    iconColor: const Color(0xFF4285F4),
                    textColor:
                        permissionState.autoStart ? Colors.green : Colors.red,
                    onTap: permissionState.autoStart
                        ? () {}
                        : () => permissionsNotifier.requestAutoStart(),
                  ),

                  SizedBox(height: 16.h),

                  // Battery Optimization
                  buildStepItem(
                    icon: Icons.battery_charging_full,
                    title: 'battery_optimization'.tr(),
                    status: permissionState.batteryOptimization
                        ? "granted".tr()
                        : "not_granted".tr(),
                    iconColor: const Color(0xFF4285F4),
                    textColor: permissionState.batteryOptimization
                        ? Colors.green
                        : Colors.red,
                    onTap: permissionState.batteryOptimization
                        ? () {}
                        : () =>
                            permissionsNotifier.requestBatteryOptimization(),
                  ),

                  SizedBox(height: 16.h),

                  // Notification Access
                  buildStepItem(
                    icon: Icons.notifications,
                    title: 'notification_access'.tr(),
                    status: permissionState.notifications
                        ? "granted".tr()
                        : "not_granted".tr(),
                    iconColor: const Color(0xFF4285F4),
                    textColor: permissionState.notifications
                        ? Colors.green
                        : Colors.red,
                    onTap: permissionState.notifications
                        ? () {}
                        : () =>
                            permissionsNotifier.requestNotifications(context),
                  ),

                  SizedBox(height: 16.h),

                  // 📍 Location Access (new)
                  buildStepItem(
                    icon: Icons.location_on_rounded,
                    title: "location_access".tr(),
                    status: permissionState.location
                        ? "granted".tr()
                        : "not_granted".tr(),
                    iconColor: const Color(0xFF4285F4),
                    textColor:
                        permissionState.location ? Colors.green : Colors.red,
                    onTap: permissionState.location
                        ? () {}
                        : () => permissionsNotifier.requestLocation(context),
                  ),

                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
