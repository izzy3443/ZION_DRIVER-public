import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/UI/Loading_UI.dart';
import 'package:zion_driver_553/UI/Permission_Item.dart';
import 'package:zion_driver_553/UI/smallUI.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/UI/trailing.dart';
import 'package:zion_driver_553/main.dart';

import 'package:zion_driver_553/pages/PERMISSION-W&F/screen_main_permission.dart';
import 'package:zion_driver_553/pages/PERMISSION-W&F/controller_main_permission.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/controller_doc_main.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/screen_doc_dl.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/screen_doc_pp.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/screen_doc_rc.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/screen_doc_name.dart';
import 'package:zion_driver_553/pages/LOGIN_PAGE-W&F/screen_vehicle.dart';
import 'package:zion_driver_553/providers/provider_user.dart';
import 'package:zion_driver_553/theme.dart';

class SetupStepsPage extends ConsumerWidget {
  SetupStepsPage({
    super.key,
  });

  bool isEditable(String status) =>
      ["Absent", "awaiting_upload", "Rejected"].contains(status);

  bool isStepCompleted(String status) =>
      status == "Pending" || status == "Approved";

  final statusDisplayMap = {
    "Absent": "not_uploaded".tr(),
    "awaiting_upload": "upload_pending".tr(),
    "Pending": "document_in_review".tr(),
    "Approved": "approved".tr(),
    "Rejected": "rejected".tr(),
  };

  final statusColorMap = {
    "Absent": Themes.fire_red,
    "awaiting_upload": Themes.fire_red,
    "Pending": Colors.orange,
    "Approved": Themes.tree_green,
    "Rejected": Themes.fire_red,
  };

  final progressProvider = Provider<double>((ref) {
    final data = ref.watch(driverDocsProvider).maybeWhen(
          data: (data) => data,
          orElse: () => null,
        );

    if (data == null) return 0.0;

    int totalSteps = 5;
    int completedSteps = 0;

    if (data.firstName != null) completedSteps++;
    if (["Pending", "Approved"].contains(data.rc.status)) completedSteps++;
    if (["Pending", "Approved"].contains(data.dl.status)) completedSteps++;
    if (["Pending", "Approved"].contains(data.pp.status)) completedSteps++;
    if (data.permission) completedSteps++;

    return completedSteps / totalSteps;
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverDocs = ref.watch(driverDocsProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      backgroundColor: Themes.white0,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'hey_user'.tr(namedArgs: {
                      'firstName': ref.read(userProvider)!.firstName ?? '',
                      'lastName': ref.read(userProvider)!.lastName ?? '',
                    }),
                    style: Themes.headline,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "complete_steps_to_start_earning".tr(),
                    style: Themes.subtitlesubText,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "start_earning_in_simple_steps".tr(),
                    style: Themes.SuperSmallContainerText,
                  ),
                ],
              ),

              SizedBox(height: 18.h),

              // Progress + List
              Expanded(
                child: driverDocs.when(
                  data: (data) {
                    return Column(
                      children: [
                        Text(
                          'progress_percent_complete'.tr(
                            namedArgs: {
                              'percent': (progress * 100).toStringAsFixed(0),
                            },
                          ),
                          style: Themes.SuperSmallContainerText,
                        ),
                        SizedBox(height: 6.h),
                        LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(7.r),
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Themes.fire_red.withOpacity(0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Themes.tree_green),
                        ),
                        SizedBox(height: 18.h),

                        // Pull-to-refresh list
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(driverDocsProvider);
                            },
                            child: ListView(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 12.h),
                                  child: Center(
                                    child: Text(
                                      'pull_down_to_refresh'
                                          .tr(), // 👈 This line uses your translation
                                      style: Themes.SuperSmallContainerText
                                          .copyWith(
                                        color: Themes.gray3,
                                      ),
                                    ),
                                  ),
                                ),
                                buildStepItem(
                                  icon: Icons.business_rounded,
                                  title: "UserName & Vehicle Type",
                                  status: data.firstName != null
                                      ? "approved".tr()
                                      : "not_uploaded".tr(),
                                  iconColor: Colors.purple,
                                  textColor: data.firstName != null
                                      ? Themes.tree_green
                                      : Themes.fire_red,
                                  onTap: isEditable(data.pp.status)
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VehicleSelectionPage(),
                                            ),
                                          );
                                        }
                                      : () {},
                                ),
                                buildStepItem(
                                  icon: Icons.directions_car_filled_rounded,
                                  title:
                                      "vehicle_registration_certificate".tr(),
                                  status: statusDisplayMap[data.rc.status]!,
                                  iconColor: Colors.blue,
                                  textColor: statusColorMap[data.rc.status]!,
                                  onTap: isEditable(data.rc.status)
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VehicleRegistrationPage(
                                                      rc: data.rc),
                                            ),
                                          );
                                        }
                                      : () {},
                                ),
                                buildStepItem(
                                  icon: Icons.credit_card_rounded,
                                  title: "driving_license".tr(),
                                  status: statusDisplayMap[data.dl.status]!,
                                  iconColor: Colors.indigo,
                                  textColor: statusColorMap[data.dl.status]!,
                                  onTap: isEditable(data.dl.status)
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DriverLicencePage(
                                                      dl: data.dl),
                                            ),
                                          );
                                        }
                                      : () {},
                                ),
                                buildStepItem(
                                  icon: Icons.account_circle_rounded,
                                  title: "profile_photo".tr(),
                                  status: statusDisplayMap[data.pp.status]!,
                                  iconColor: Colors.orange,
                                  textColor: statusColorMap[data.pp.status]!,
                                  onTap: isEditable(data.pp.status)
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Upload(pp: data.pp),
                                            ),
                                          );
                                        }
                                      : () {},
                                ),
                                buildStepItem(
                                  icon: Icons.security_rounded,
                                  title: "grant_permissions".tr(),
                                  status: data.permission
                                      ? "granted".tr()
                                      : "required".tr(),
                                  iconColor: Colors.teal,
                                  textColor: data.permission
                                      ? Themes.tree_green
                                      : Themes.fire_red,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            GrantPermissionsPage(),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  error: (error, stack) {
                    return Center(child: Text("something_went_wrong".tr()));
                  },
                  loading: () => Center(child: LoadingCircle(true)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
