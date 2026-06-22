import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zion_driver_553/UI/AppBar(ZION).dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/icon_button.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/UI/text_points.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/controller_doc_main.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/screen_doc%20_main.dart';
import 'package:zion_driver_553/theme.dart';
import 'package:zion_driver_553/providers/provider_user.dart';

class DocumentUploadPage extends ConsumerWidget {
  final String title;
  String? frontUrl;
  String? backUrl;
  final String path;
  DocumentUploadPage(
      {Key? key,
      required this.title,
      required this.frontUrl,
      required this.backUrl,
      required this.path})
      : super(key: key);

  final frontImageProvider = StateProvider<XFile?>((ref) => null);
  final backImageProvider = StateProvider<XFile?>((ref) => null);
  final isLoadingProvider = StateProvider<bool>((ref) => false);

  Future<void> pickImage(
      WidgetRef ref, bool isFront, ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      if (isFront) {
        ref.read(frontImageProvider.notifier).state = pickedFile;
      } else {
        ref.read(backImageProvider.notifier).state = pickedFile;
      }
    }
  }

  Future<void> uploadDocuments(WidgetRef ref, BuildContext context) async {
    final frontFile = ref.read(frontImageProvider);
    final backFile = ref.read(backImageProvider);

    if (frontFile == null || backFile == null) {
      showCustomSnackBar(context, "please_upload_both_sides".tr());
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;

    try {
      final uid = ref.read(userProvider)!.uid;
      final basePath = "documents/$uid/$title";
      final frontRef =
          FirebaseStorage.instance.ref().child("$basePath-front.jpg");
      final backRef =
          FirebaseStorage.instance.ref().child("$basePath-back.jpg");

      final frontSnap = await frontRef.putFile(File(frontFile.path));
      final backSnap = await backRef.putFile(File(backFile.path));

      final frontUrl = await frontSnap.ref.getDownloadURL();
      final backUrl = await backSnap.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("drivers")
          .doc(uid)
          .collection("driver_documents")
          .doc(path)
          .update({
        "frontUrl": frontUrl,
        "backUrl": backUrl,
        "Status": "Pending",
        "uploadedAt": FieldValue.serverTimestamp(),
      });

      showCustomSnackBar(
        context,
        'title_uploaded_successfully'.tr(namedArgs: {'title': title}),
      );
      ref.invalidate(driverDocsProvider);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => SetupStepsPage()),
        (route) => route.isFirst, // removes all routes except the first
      );
    } catch (e) {
      showCustomSnackBar(context, "upload_failed_try_again".tr());
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Widget imageContainer(String label, XFile? file, String? url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Themes.subtitle),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          height: 180.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: () {
            if (file != null) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.file(
                  File(file.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 180.h,
                ),
              );
            } else if (url != null && url.isNotEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 180.h,
                ),
              );
            } else {
              return const Center(
                child: Icon(Icons.image_not_supported,
                    size: 50, color: Colors.grey),
              );
            }
          }(),
        ),
      ],
    );
  }

  Widget uploadButtons(WidgetRef ref, bool isFront) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: customIconTextButton(
              "gallery".tr(),
              Icons.photo_library_rounded,
              onPressed: () => pickImage(ref, isFront, ImageSource.gallery),
              backgroundColor: const Color(0xFFE0F7FA),
              fontColor: Colors.black87,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: customIconTextButton(
              "camera".tr(),
              Icons.photo_camera_rounded,
              onPressed: () => pickImage(ref, isFront, ImageSource.camera),
              backgroundColor: const Color(0xFFE0F7FA),
              fontColor: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);
    final frontImage = ref.watch(frontImageProvider);
    final backImage = ref.watch(backImageProvider);

    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(20.r),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Upload $title",
                  style:
                      Themes.headline2.copyWith(fontWeight: FontWeight.w500)),

              SizedBox(height: 10.h),
              buildStep('1', 'upload_both_sides_clearly'.tr()),
              buildStep('2', 'crop_images_properly'.tr()),
              buildStep('3', 'avoid_reuploading_unless_mistake'.tr()),
              buildStep('4', 'no_glare_blur_cut_edges'.tr()),

              SizedBox(height: 30.h),

              // Front Side
              imageContainer("front_side".tr(), frontImage, frontUrl),
              uploadButtons(ref, true),

              SizedBox(height: 16.h),

              // Back Side
              imageContainer("back_side".tr(), backImage, backUrl),
              uploadButtons(ref, false),

              SizedBox(height: 30.h),
              customButton(
                text: "upload_document".tr(),
                isLoading: isLoading,
                onPressed: () => uploadDocuments(ref, context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
