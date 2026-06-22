import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slide_to_act/slide_to_act.dart';

import 'package:zion_driver_553/TRIPPAGE-W&F/screen_trippage.dart';
import 'package:zion_driver_553/UI/Activity_card.dart';
import 'package:zion_driver_553/UI/Loading_UI.dart';
import 'package:zion_driver_553/UI/pullUpBar.dart';
import 'package:zion_driver_553/UI/red_dot.dart';
import 'package:zion_driver_553/UI/smallUI.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/UI/swipe_button.dart';
import 'package:zion_driver_553/RAZORPAY-W&F/screen_subscription.dart';
import 'package:zion_driver_553/getstarted_page.dart';
import 'package:zion_driver_553/global_methods/loading.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/models/driver_home_model.dart';
import 'package:zion_driver_553/models/trip_details_model.dart';

import 'package:zion_driver_553/pages/HOME_PAGE-W&F/controller_dashboard.dart';
import 'package:zion_driver_553/pages/HOME_PAGE-W&F/screen_HomeMap.dart';

import 'package:zion_driver_553/pages/HOME_PAGE-W&F/screen_profilepage.dart';
import 'package:zion_driver_553/pages/HOME_PAGE-W&F/screen_trips.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/screen_doc%20_main.dart';
import 'package:zion_driver_553/pages/LOGIN_PAGE-W&F/screen_login.dart';
import 'package:zion_driver_553/providers/provider_user.dart';
import 'package:zion_driver_553/theme.dart';
import 'package:zion_driver_553/pages/TRIP_REQ-W&F/kotlin_channel.dart';

class DriverHomePage extends ConsumerStatefulWidget {
  const DriverHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends ConsumerState<DriverHomePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    /// INIT (EVENTS ONLY)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final event =
          await ref.read(driverHomeControllerProvider.notifier).init();
      if (!mounted) return;
      _handleEvent(event);
    });

    /// CAMERA ANIMATION (PERF SAFE)
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  /// OLD BEHAVIOR — PRESERVED
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await checkAndHandlePendingTrip(context, ref);
    });
  }

  /// OLD BEHAVIOR — PRESERVED
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await checkAndHandlePendingTrip(context, ref);
      });
    }
  }

  void _handleEvent(DriverHomeEvent event) {
    switch (event) {
      case DriverHomeEvent.goToTrip:
        final trip = ref.read(tripDetailsProvider);
        if (trip == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Newtrippage(
              isExistingTripStatus: true,
            ),
          ),
        );
        break;

      case DriverHomeEvent.notLoggedIn:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        break;

      case DriverHomeEvent.userDocMissing:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GetstartedPage()),
        );
        break;

      case DriverHomeEvent.permissionRequired:
        showCustomSnackBar(context, "Location permission required");
        break;

      case DriverHomeEvent.subscriptionInactive:
        showCustomSnackBar(context, "Subscription inactive");
        break;

      case DriverHomeEvent.error:
        showCustomSnackBar(context, "Something went wrong");
        break;

      case DriverHomeEvent.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HomeDrawer(),
      body: Stack(
        children: [
          const HomeMapView(),
          const HomeMenuButton(),
          HomeBottomSheet(onEvent: _handleEvent),
        ],
      ),
    );
  }
}

class HomeMenuButton extends StatelessWidget {
  const HomeMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20.h,
      left: 16.w,
      child: SafeArea(
        child: Builder(
          builder: (context) => Container(
            decoration: BoxDecoration(
              color: Themes.white0,
              shape: BoxShape.circle,
              boxShadow: boxShadow(),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
                size: 27,
              ),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeBottomSheet extends ConsumerWidget {
  final void Function(DriverHomeEvent) onEvent; // 🔥 Add callback parameter

  const HomeBottomSheet({
    super.key,
    required this.onEvent, // 🔥 Required callback
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(
      driverHomeControllerProvider.select((s) => s.isOnline),
    );
    final isLoading = ref.watch(
      driverHomeControllerProvider.select((s) => s.isLoading),
    );
    final user = ref.watch(userProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Themes.white0,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: boxShadow(),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            controller: controller,
            children: [
              if (user == null) ...[
                SizedBox(height: 12.h),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 1.h),
                  child: LoadingLine(true),
                ),
              ] else ...[
                Center(child: pullUpBar()),
                SizedBox(height: 8.h),
                modernDriverSwipeButton(
                  text: isOnline ? 'go_offline'.tr() : 'go_online'.tr(),
                  isLoading: isLoading,
                  outerColor: isOnline ? Themes.fire_red : Themes.tree_green,
                  onSubmit: () async {
                    final event = await ref
                        .read(driverHomeControllerProvider.notifier)
                        .toggleOnline();

                    onEvent(event); // 🔥 Call the callback
                  },
                ),
                SizedBox(height: 8.h),
                driverStatusBadge(isOnline),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: buildActivityCard(
                        title: "earnings_today".tr(),
                        value: "₹${user.earningsToday?.toStringAsFixed(2)}",
                        subtitle: 'with Zion',
                        icon: Icons.currency_rupee_sharp,
                        color: Themes.black3,
                        textColor: Themes.white0,
                        showProgress: false,
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: buildActivityCard(
                        title: "trips_today".tr(),
                        value: user.ridesToday.toString(),
                        subtitle: "With Zion",
                        icon: Icons.directions_car_outlined,
                        color: Color.fromRGBO(255, 248, 225, 1),
                        textColor: Themes.black0,
                        showProgress: false,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

Widget driverStatusBadge(bool isOnline) {
  final isOnlineColor = Color(0xFF2E7D32); // Green
  final isOfflineColor = Color(0xFFE57373); // Light red
  final isOnlineBgColor = Color(0xFFE8F5E9); // Light green
  final isOfflineBgColor = Color(0xFFFFF5F5); // Very light red

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    decoration: BoxDecoration(
      color: isOnline ? isOnlineBgColor : isOfflineBgColor,
      border: Border.all(
        color: isOnline ? isOnlineColor : isOfflineColor,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: (isOnline ? isOnlineColor : isOfflineColor).withOpacity(0.4),
          blurRadius: 10,
          spreadRadius: 1,
          offset: Offset(0, 0), // Glows evenly around
        ),
      ],
    ),
    child: Center(
      child: Text(
        isOnline ? 'you_are_online'.tr() : 'you_are_offline'.tr(),
        style: Themes.subtitleText.copyWith(
          color: isOnline ? isOnlineColor : isOfflineColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return Drawer(
        backgroundColor: Themes.white0,
        child: Center(child: LoadingCircle(true)),
      );
    }

    return Drawer(
      backgroundColor: Themes.white0,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 7.w),
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Themes.gray1,
                    backgroundImage: user.profilePic?.isNotEmpty == true
                        ? NetworkImage(user.profilePic!)
                        : null,
                    child: user.profilePic?.isEmpty != false
                        ? const Icon(Icons.person,
                            size: 40, color: Themes.black1)
                        : null,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "${user.firstName ?? ""} ${user.lastName ?? ""}".trim(),
                    style: Themes.headline3,
                  ),
                ],
              ),
            ),
            _drawerItem(
              Icons.person,
              "my_profile".tr(),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              ),
            ),
            _drawerItem(
              Icons.history,
              "trips_and_earnings".tr(),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DriverTripsHistoryPage()),
              ),
            ),
            _drawerItem(
              Icons.verified_user_outlined,
              "documents".tr(),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SetupStepsPage()),
              ),
              showDot: !(user.isVerified ?? false),
            ),
            _drawerItem(
              Icons.subscriptions_outlined,
              "subscription".tr(),
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PackageScreen()),
              ),
              showDot: !(user.subscriptionActive ?? false),
            ),
            _drawerItem(Icons.help_outline, "help".tr(), () {}),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool showDot = false,
  }) {
    return ListTile(
      leading: Stack(
        children: [
          Icon(icon, color: Themes.black2),
          if (showDot) Positioned(right: 0, top: 0, child: redDot()),
        ],
      ),
      title: Text(title, style: Themes.subtitleText),
      onTap: onTap,
    );
  }
}
