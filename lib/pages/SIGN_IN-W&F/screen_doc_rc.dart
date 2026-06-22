import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:googleapis/monitoring/v3.dart';
import 'package:googleapis/playcustomapp/v1.dart';
import 'package:zion_driver_553/UI/AppBar(ZION).dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/TextField.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/UI/text_container.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/models/driver_doc_model.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/controller_doc_main.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/screen_doc_upload.dart';
import 'package:zion_driver_553/theme.dart';
import 'package:zion_driver_553/providers/provider_user.dart';

class VehicleRegistrationPage extends ConsumerStatefulWidget {
  final RegistrationCertificateDoc rc;
  const VehicleRegistrationPage({Key? key, required this.rc}) : super(key: key);

  @override
  ConsumerState<VehicleRegistrationPage> createState() =>
      _VehicleRegistrationPageState();
}

class _VehicleRegistrationPageState
    extends ConsumerState<VehicleRegistrationPage> {
  final TextEditingController regNoController = TextEditingController();
  final TextEditingController reRegNoController = TextEditingController();
  final StateProvider<bool> isLoadingProvider =
      StateProvider<bool>((ref) => false);

  // You can pass the RegistrationCertificateDoc if needed
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final regNo = widget.rc.Number;
      if (regNo != null && regNo.isNotEmpty) {
        regNoController.text = regNo;
        reRegNoController.text = regNo;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.white0,
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "vehicle_registration_details".tr(),
                style: Themes.headline2
                    .copyWith(height: 0.0.h, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 14.h),

              Text(
                "vehicle_registration_certificate_number".tr(),
                style: Themes.subtitlesubText.copyWith(fontSize: 16.sp),
              ),
              if (widget.rc.rejectionReason != null) ...[
                SizedBox(height: 20.h),
                appMessageContainer(
                  message: "Rejection Reason: ${widget.rc.rejectionReason}",
                  icon: Icons.info_outline,
                  backgroundColor: Colors.red[800],
                  textColor: Colors.white,
                ),
              ],

              SizedBox(height: 10.h),
              textField(
                regNoController,
                widget.rc.Number ?? "enter_vehicle_no".tr(),
                icon: Icons.directions_car_rounded,
              ),

              SizedBox(height: 24.h),

              // Field 2 label
              Text(
                "reenter_vehicle_registration_number".tr(),
                style: Themes.subtitlesubText.copyWith(fontSize: 15.sp),
              ),

              SizedBox(height: 10.h),
              textField(
                reRegNoController,
                widget.rc.Number ?? "reenter_vehicle_no".tr(),
                icon: Icons.repeat_rounded,
              ),

              SizedBox(height: 14.h),

              // Upload button
              customButton(
                  text: "upload_rc".tr(),
                  onPressed: () => onPressed(ref),
                  isLoading: ref.watch(isLoadingProvider)),
            ],
          ),
        ),
      ),
    );
  }

  void onPressed(WidgetRef ref) {
    // Handle the upload logic here

    final regNo = regNoController.text.trim();
    final reRegNo = reRegNoController.text.trim();

    if (regNo.isNotEmpty && regNo == reRegNo) {
      ref.read(isLoadingProvider.notifier).state = true;
      FirebaseFirestore.instance
          .collection("drivers")
          .doc(ref.read(userProvider)!.uid)
          .collection("driver_documents")
          .doc("RegistrationCertificate")
          .set({
        "RCNumber": regNo,
        "Status": "awaiting_upload",
        "Timestamp": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).then((_) {
        ref.invalidate(driverDocsProvider);
        ref.read(isLoadingProvider.notifier).state = false;
        Navigator.push(
          ref.context,
          MaterialPageRoute(
            builder: (context) => DocumentUploadPage(
                title: "RC",
                frontUrl: widget.rc.frontImage,
                backUrl: widget.rc.backImage,
                path: "RegistrationCertificate"),
          ),
        );
      }).catchError((error) {
        ref.read(isLoadingProvider.notifier).state = false;
        showCustomSnackBar(ref.context, "something_went_wrong".tr());
      });
    } else {
      showCustomSnackBar(
        ref.context,
        "please_ensure_fields_match".tr(),
      );
    }
  }
}
