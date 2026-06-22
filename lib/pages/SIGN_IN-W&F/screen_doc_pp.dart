import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zion_driver_553/UI/AppBar(ZION).dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/Loading_UI.dart';
import 'package:zion_driver_553/UI/icon_button.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/UI/text_container.dart';
import 'package:zion_driver_553/UI/text_points.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/models/driver_doc_model.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/controller_doc_main.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/screen_doc%20_main.dart';
import 'package:zion_driver_553/theme.dart';
import 'package:zion_driver_553/providers/provider_user.dart';

class Upload extends ConsumerWidget {
  final ProfilePhotoDoc? pp;
  Upload({Key? key, this.pp}) : super(key: key);

  final imageFileProvider = StateProvider<XFile?>((ref) => null);
  final isLoadingProvider = StateProvider<bool>((ref) => false);

  Future<void> chooseImageFromGallery(WidgetRef ref) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      ref.read(imageFileProvider.notifier).state = pickedFile;
    }
  }

  Future<void> takeImageFromCamera(WidgetRef ref) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      ref.read(imageFileProvider.notifier).state = pickedFile;
    }
  }

  Future<void> uploadImageToStorage(WidgetRef ref, BuildContext context) async {
    final imageFile = ref.read(imageFileProvider);
    if (imageFile == null) {
      showCustomSnackBar(context, "please_select_an_image".tr());
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;

    try {
      final uid = ref.read(userProvider)!.uid;
      final basePath = "documents/$uid/profile_photo";
      final profileref =
          FirebaseStorage.instance.ref().child("$basePath-profile.jpg");

      final profilepicSnapshot = await profileref.putFile(File(imageFile.path));

      final downloadUrl = await profilepicSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("drivers")
          .doc(ref.read(userProvider)!.uid)
          .collection("driver_documents")
          .doc("ProfilePhoto")
          .set({
        "PhotoURL": downloadUrl,
        "Status": "Pending",
        "Timestamp": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).then((_) {
        ref.invalidate(driverDocsProvider);
        ref.read(isLoadingProvider.notifier).state = false;
      });

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => SetupStepsPage()),
        (route) => route.isFirst, // removes all routes except the first
      );

      // Log or use the URL as needed
      debugPrint("Uploaded Image URL: $downloadUrl");
      showCustomSnackBar(context, "image_uploaded_successfully".tr());
    } catch (e) {
      showCustomSnackBar(context, "image_upload_failed_try_again".tr());
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageFile = ref.watch(imageFileProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(20.r),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("upload_profile_photo".tr(),
                  style: Themes.headline2
                      .copyWith(height: 0.0.h, fontWeight: FontWeight.w500)),
              SizedBox(height: 10.h),
              buildStep('1', 'make_sure_face_visible'.tr()),
              buildStep('2', 'only_face_should_be_visible'.tr()),
              buildStep('3', 'make_sure_face_matches_id'.tr()),
              if (pp?.rejectionReason != null) ...[
                SizedBox(height: 20.h),
                appMessageContainer(
                  message: "Rejection Reason: ${pp!.rejectionReason}",
                  icon: Icons.info_outline,
                  backgroundColor: Colors.red[800],
                  textColor: Colors.white,
                ),
              ],
              SizedBox(height: 30.h),
              imageFile == null
                  ? const Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Center(
                      child: Container(
                        width: 120.w,
                        height: 120.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: FileImage(File(imageFile.path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 20.h),
              Center(
                child: customIconTextButton(
                  "camera".tr(),
                  Icons.photo_camera_rounded,
                  onPressed: () => takeImageFromCamera(ref),
                  backgroundColor: const Color(0xFFF3F4F6),
                  fontColor: Colors.black,
                ),
              ),
              SizedBox(height: 30.h),
              customButton(
                text: "upload".tr(),
                onPressed: () => uploadImageToStorage(ref, context),
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
