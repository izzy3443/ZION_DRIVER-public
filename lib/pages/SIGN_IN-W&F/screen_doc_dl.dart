import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:zion_driver_553/UI/AppBar(ZION).dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/TextField.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/UI/text_container.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/models/driver_doc_model.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/screen_doc_upload.dart';
import 'package:zion_driver_553/theme.dart';
import 'package:zion_driver_553/providers/provider_user.dart';

class DriverLicencePage extends ConsumerStatefulWidget {
  final DriverLicenceDoc dl;
  const DriverLicencePage({super.key, required this.dl});

  @override
  ConsumerState<DriverLicencePage> createState() => _DriverLicencePageState();
}

class _DriverLicencePageState extends ConsumerState<DriverLicencePage> {
  final TextEditingController dlController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final StateProvider<bool> isLoadingProvider =
      StateProvider<bool>((ref) => false);

  @override
  void initState() {
    super.initState();

    // Assign values after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final DlNo = widget.dl.dlNumber;
      if (DlNo != null && DlNo.isNotEmpty) {
        dlController.text = DlNo;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.dl.dob != null
          ? DateFormat('dd/MM/yyyy').parse(widget.dl.dob!)
          : DateTime(now.year - 20),
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Themes.fire_red,
              onPrimary: Themes.white0,
              onSurface: Themes.black1,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Themes.fire_red,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.white0,
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "driver_licence_details".tr(),
                  style: Themes.headline2
                      .copyWith(height: 0.0.h, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 14.h),
                Text(
                  "driving_licence_number".tr(),
                  style: Themes.subtitlesubText.copyWith(fontSize: 15.sp),
                ),
                if (widget.dl.rejectionReason != null) ...[
                  SizedBox(height: 20.h),
                  appMessageContainer(
                    message: "Rejection Reason: ${widget.dl.rejectionReason}",
                    icon: Icons.info_outline,
                    backgroundColor: Colors.red[800],
                    textColor: Colors.white,
                  ),
                ],
                SizedBox(height: 10.h),
                textField(
                  dlController,
                  "enter_dl_number".tr(),
                  icon: Icons.credit_card_rounded,
                ),
                SizedBox(height: 24.h),
                Text(
                  "date_of_birth_dob".tr(),
                  style: Themes.subtitlesubText.copyWith(fontSize: 15.sp),
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: textField(
                      dobController,
                      "select_date_of_birth".tr(),
                      icon: Icons.calendar_today_rounded,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                customButton(
                  text: 'upload'.tr(),
                  onPressed: () {
                    onPressed(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onPressed(BuildContext context) async {
    // Handle the upload logic here
    final dl = dlController.text.trim();
    final dob = dobController.text.trim();

    if (dl.isNotEmpty && dob.isNotEmpty) {
      ref.read(isLoadingProvider.notifier).state = true;
      await FirebaseFirestore.instance
          .collection("drivers")
          .doc(ref.read(userProvider)!.uid)
          .collection("driver_documents")
          .doc("DriverLicence")
          .set({
        "DrivingLicenceNumber": dl,
        "DateOfBirth": dob,
        "Status": "awaiting_upload",
        "Timestamp": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).then((_) {
        ref.read(isLoadingProvider.notifier).state = false;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentUploadPage(
              frontUrl: widget.dl.frontImage,
              backUrl: widget.dl.backImage,
              title: "Driving Licence",
              path: "DriverLicence",
            ),
          ),
        );
      }).catchError((error) {
        ref.read(isLoadingProvider.notifier).state = false;
        showCustomSnackBar(ref.context, "something_went_wrong".tr());
      });
    } else {
      if (dob.isEmpty) {
        showCustomSnackBar(context, "please_select_dob".tr());
      } else {
        showCustomSnackBar(context, "please_enter_dl_number".tr());
      }
    }
  }
}
