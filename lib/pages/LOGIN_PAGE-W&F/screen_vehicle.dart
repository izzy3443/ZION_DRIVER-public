import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/UI/AppBar(ZION).dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/Image_item.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/models/user_model.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/screen_doc_name.dart';
import 'package:zion_driver_553/paths.dart';
import 'package:zion_driver_553/providers/provider_user.dart';
import 'package:zion_driver_553/theme.dart';

import 'package:flutter/material.dart';
// Replace if needed

class VehicleSelectionPage extends ConsumerWidget {
  final StateProvider<bool> isLoadingProvider =
      StateProvider<bool>((ref) => false);
  final selectedIndexProvider = StateProvider<int>((ref) => -1);

  final List<Map<String, String>> vehicleOptions = [
    {
      'title': 'car_owner'.tr(),
      'description': 'car_owner_desc'.tr(),
      'image': car_front,
    },
    {
      'title': 'auto_owner'.tr(),
      'description': 'You wish to drive an Auto'.tr(),
      'image': auto_front,
    },
  ];

  // Maps selectedIndex to vehicle type string
  String? getSelctedVehicleType(WidgetRef ref) {
    switch (ref.read(selectedIndexProvider)) {
      case 0:
        return "Car";
      case 1:
        return "Auto";
      default:
        return null;
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final isLoading = ref.watch(isLoadingProvider);
    final selectedIndex = ref.watch(selectedIndexProvider);
    final user = ref.watch(userProvider)!;
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Themes.white0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  "choose_your_type_with_zion".tr(),
                  style: Themes.headline.copyWith(height: 0.0.h),
                ),
              ),

              SizedBox(height: 30.h),

              // Vehicle Options List
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: vehicleOptions.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicleOptions[index];
                  return vehicleOptionItem(
                    title: vehicle['title']!,
                    description: vehicle['description']!,
                    imagePath: vehicle['image']!,
                    isSelected: selectedIndex == index,
                    onTap: () {
                      ref.read(selectedIndexProvider.notifier).state = index;
                      // Optionally, you can also navigate to the next page here
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => NextPage()));
                    },
                  );
                },
              ),

              // Continue Button
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 24.h),
                child: customButton(
                  text: "continue".tr(),
                  onPressed:
                      selectedIndex != -1 ? () => onPressed(ref, user) : null,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onPressed(WidgetRef ref, AppUser user) {
    if (ref.read(selectedIndexProvider) != -1) {
      final type = getSelctedVehicleType(ref);
      if (type != null) {
        ref.read(isLoadingProvider.notifier).state = true;
        FirebaseFirestore.instance
            .collection('drivers')
            .doc(ref.read(userProvider)!.uid)
            .update({'VehicleType': type});
        ref.read(isLoadingProvider.notifier).state = false;
        Navigator.push(
          ref.context,
          MaterialPageRoute(
            builder: (_) => NameUpload(
              firstName: user.firstName,
              lastName: user.lastName,
            ),
          ),
        );
      }
    } else {
      showCustomSnackBar(ref.context, "please_select_a_vehicle_type".tr());
    }
  }
}
