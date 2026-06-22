import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/UI/Activity_card.dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/Loading_UI.dart';
import 'package:zion_driver_553/UI/smallUI.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/UI/trailing.dart';
import 'package:zion_driver_553/getstarted_page.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/models/user_model.dart';
import 'package:zion_driver_553/providers/provider_user.dart';
import 'package:zion_driver_553/theme.dart';
import 'package:zion_driver_553/pages/LOGIN_PAGE-W&F/screen_language.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    // Set status bar to transparent with dark icons

    return Scaffold(
      backgroundColor: Themes.white0,
      body: SafeArea(
        child: SingleChildScrollView(
          child: user != null
              ? Column(
                  children: [
                    _buildHeader(user.firstName!, user.lastName!,
                        ref.read(userProvider)?.profilePic),
                    _buildBalanceCard(user),
                    // _buildQuickActions(),
                    _buildActivityOverview(user),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0.w, vertical: 12.h),
                      child: customButton(
                        text: 'change_language'.tr(),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LanguageSelectionPage(isToLogin: false),
                            ),
                          );
                        },
                      ),
                    ),
                    _buildMenuOptions(context),

                    SizedBox(height: 20.h),
                  ],
                )
              : Center(child: LoadingCircle(false)),
        ),
      ),
    );
  }

  Widget _buildHeader(String firstname, String lastname, String? profilePic) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22.w, 20.h, 20.w, 25.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  color: Themes.white1,
                  image: profilePic != null && profilePic.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(profilePic),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: profilePic == null || profilePic.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 40,
                        color: Themes.gray3,
                      )
                    : null,
              ),
              SizedBox(width: 15.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'hi_welcome_back'.tr(),
                    style: Themes.subtitlesubText.copyWith(
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "${firstname} ${lastname}",
                    style: Themes.headline2,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration GradientContaierDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A1A1A),
          Color(0xFF303030),
        ],
      ),
      borderRadius: BorderRadius.circular(24.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(AppUser user) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 25.h),
      padding: EdgeInsets.all(20.r),
      decoration: GradientContaierDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total_rides_today'.tr(),
                style: Themes.subtitleText.copyWith(
                  color: Themes.white0,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text('ZION',
                    style: Themes.SuperSmallContainerText.copyWith(
                        letterSpacing: -0.7,
                        fontWeight: FontWeight.w600,
                        color: Themes.white0)),
              ),
            ],
          ),

          SizedBox(height: 5.h),
          //Colors.white.withOpacity(0.7)
          Text(
            'With Zion',
            style: Themes.buttonTextlogin.copyWith(
              color: Themes.gray3,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),

          SizedBox(height: 10.h),
          Text(
            'Rides ${user.totalTrips ?? '0'}',
            style: Themes.buttonTextlogin.copyWith(
              fontSize: 36.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: -1,
            ),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildActivityOverview(AppUser user) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 25.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Build_title_('activity_overview'.tr()),
          SizedBox(height: 15.h),
          Row(
            children: [
              Expanded(
                child: buildActivityCard(
                  title: 'rating'.tr(),
                  value: ' ${user.rating.toString()} ⭐ ',
                  subtitle: "With Zion",
                  icon: Icons.directions_car_outlined,
                  color: const Color(0xFFFFF8E1),
                  textColor: Themes.black0,
                  showProgress: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Make sure you import this

  Widget _buildMenuOptions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: GestureDetector(
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  // Navigate to login screen or splash screen after logout
                  // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const GetstartedPage()),
                    (route) => false,
                  );
                } catch (e) {
                  showCustomSnackBar(context, "Error logging out");
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: boxShadow(),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        size: 20,
                        color: Themes.fire_red,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'log_out'.tr(),
                        style: Themes.MidContainerText.copyWith(
                          color: Themes.fire_red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Activity Overview
  Widget Build_title_(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Themes.headline2,
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'see_all'.tr(),
            style: Themes.subtitlesubText.copyWith(
              color: Themes.fire_red,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
