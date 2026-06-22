import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zion_driver_553/UI/AppBar(ZION).dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/TextField.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/auth/error_firebase.dart';
import 'package:zion_driver_553/providers/provider_user.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/screen_doc%20_main.dart';
import 'package:zion_driver_553/paths.dart';
import 'package:zion_driver_553/theme.dart';

// Adjust import as necessary

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NameUpload extends ConsumerWidget {
  String? firstName;
  String? lastName;
  NameUpload({
    super.key,
    this.firstName,
    this.lastName,
  });

  final isLoadingProvider = StateProvider<bool>((ref) => false);

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  Future<void> sendDataToDatabase(WidgetRef ref) async {
    final currentuserFrmProvider = ref.read(userProvider)!;

    final uid = currentuserFrmProvider.uid;

    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
      showCustomSnackBar(ref.context, "please_enter_both_names".tr());
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference userdocRef = firestore.collection("drivers").doc(uid);

    Map<String, dynamic> userDataMap = {
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
    };

    try {
      await userdocRef.set(userDataMap, SetOptions(merge: true));

      ref.read(userProvider.notifier).updateName(
            firstName: firstNameController.text,
            lastName: lastNameController.text,
          );

      ref.read(isLoadingProvider.notifier).state = false;

      Navigator.of(ref.context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SetupStepsPage(),
        ),
      );
    } catch (e) {
      ref.read(isLoadingProvider.notifier).state = false;
      showCustomSnackBar(ref.context, "Error uploading data");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Themes.white0,
      body: Padding(
        padding: EdgeInsets.all(16.0.r),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'enter_your_name_to_continue'.tr(),
                style: Themes.headline2
                    .copyWith(height: 0.0.h, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 14.h),
              Text("instructions_enter_name_on_dl".tr(),
                  style: Themes.subtitlesubText),
              SizedBox(height: 30.h),
              Text("first_name".tr(), style: Themes.subtitle),
              SizedBox(height: 5.h),
              textField(firstNameController,
                  firstName ?? "enter_your_first_name".tr()),
              SizedBox(height: 15.h),
              Text("last_name".tr(), style: Themes.subtitle),
              SizedBox(height: 5.h),
              textField(
                  lastNameController, lastName ?? "enter_your_last_name".tr()),
              SizedBox(height: 20.h),
              customButton(
                text: "continue".tr(),
                isLoading: isLoading,
                onPressed: () => sendDataToDatabase(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// they dont contunally listen u gotta make them listen TALKING ABOUT SETSTATES
