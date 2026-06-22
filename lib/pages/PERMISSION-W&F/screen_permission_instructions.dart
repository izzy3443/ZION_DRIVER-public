import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/UI/text_points.dart';
import 'package:zion_driver_553/theme.dart';
// Adjust the path as needed

class PermissionInstructionsPage extends StatelessWidget {
  final String permissionName;
  final IconData icon;
  final String emoji;

  const PermissionInstructionsPage({
    super.key,
    required this.permissionName,
    required this.icon,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.white0,
      appBar: AppBar(
        backgroundColor: Themes.white0,
        elevation: 0,
        iconTheme: const IconThemeData(color: Themes.black0),
        title: Text(
          '$emoji $permissionName Access',
          style: Themes.headline3,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'why_we_need'.tr(),
              style: Themes.headline2,
            ),
            SizedBox(height: 10.h),
            Text(
              'to_function_properly_the_app_needs_access_to_your_permissionname'
                  .tr(namedArgs: {'permissionName': permissionName}),
              style: Themes.bodyText1,
            ),
            SizedBox(height: 25.h),
            buildStep('1', 'open_your_phone_settings'.tr()),
            buildStep('2', 'go_to_apps_or_app_management'.tr()),
            buildStep('3', 'find_and_tap_on_zion_driver_app'.tr()),
            buildStep('4', 'tap_on_permissions'.tr()),
            buildStep(
              '5',
              'enable_permissionname_permission'
                  .tr(namedArgs: {'permissionName': permissionName}),
            ),
            SizedBox(height: 30.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Themes.selected_red,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'note_device_specific_permissions'.tr(),
                style: Themes.subtitlesubText,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Themes.black0,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('go_back', style: Themes.buttonText),
              ),
            )
          ],
        ),
      ),
    );
  }
}
