import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zion_driver_553/TRIPPAGE-W&F/controller_trippage.dart';
import 'package:zion_driver_553/models/trip_state_model.dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/Loading_UI.dart';
import 'package:zion_driver_553/UI/smallUI.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/UI/swipe_button.dart';
import 'package:zion_driver_553/pages/CHAT_PAGE-W&F/controller_RideChat.dart';
import 'package:zion_driver_553/pages/CHAT_PAGE-W&F/screen_RideChat.dart';
import 'package:zion_driver_553/TRIPPAGE-W&F/screen_ride_cancel.dart';
import 'package:zion_driver_553/TRIPPAGE-W&F/screen_otp.dart';
import 'package:zion_driver_553/TRIPPAGE-W&F/screen_ride_force_end.dart';
import 'package:zion_driver_553/pages/HOME_PAGE-W&F/screen_HomeMap.dart';
import 'package:zion_driver_553/TRIPPAGE-W&F/screen_fare_collection.dart';
import 'package:zion_driver_553/models/trip_details_model.dart';
import 'package:zion_driver_553/pages/HOME_PAGE-W&F/screen_dashboard.dart';
import 'package:zion_driver_553/providers/provider_marker.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/theme.dart';
import 'package:zion_driver_553/var/global_var.dart';
import 'package:zion_driver_553/var/bitmap.dart';
import 'package:zion_driver_553/providers/provider_user.dart';

class Newtrippage extends ConsumerStatefulWidget {
  final bool isExistingTripStatus;

  const Newtrippage({super.key, required this.isExistingTripStatus});

  @override
  ConsumerState<Newtrippage> createState() => _NewtrippageState();
}

class _NewtrippageState extends ConsumerState<Newtrippage> {
  GoogleMapController? _mapController;
  StreamSubscription<TripEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTrip();
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeTrip() async {
    final trip = ref.read(tripDetailsProvider);
    if (trip == null) return;

    try {
      // Fetch user info
      await _fetchUserInfo(trip.UserId);

      // Initialize trip controller
      await ref.read(tripControllerProvider.notifier).initTrip(trip);

      // Listen to events
      _listenToEvents();
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, "Error initializing trip");
      }
    }
  }

  Future<void> _fetchUserInfo(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();

    if (userDoc.exists) {
      final userData = userDoc.data()!;
      ref.read(tripDetailsProvider.notifier).enrichWithUserInfo(userData);
    }
  }

  void _listenToEvents() {
    final controller = ref.read(tripControllerProvider.notifier);
    _eventSubscription = controller.events.listen((event) {
      if (mounted) {
        _handleEvent(event);
      }
    });

    // Listen to status changes for cancellation
    // ref.listen<String>(
    //   tripControllerProvider.select((state) => state.status),
    //   (previous, next) {
    //     if (next == 'cancelledByUser') {
    //       _handleCancellation();
    //     }
    //   },
    // );
  }

  void _handleCancellation() {
    ref.read(markerSetNotifierProvider.notifier).clearMarkers();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => DriverHomePage()),
    );
    showCustomSnackBar(context, "trip_cancelled_by_user".tr());
  }

  void _handleEvent(TripEvent event) {
    final trip = ref.read(tripDetailsProvider);
    if (trip == null) return;

    switch (event) {
      case TripEvent.tripCancelled:
        _handleCancellation();
        break;

      case TripEvent.arrivedSuccess:
        showCustomSnackBar(context, "You have arrived at pickup location");
        break;

      case TripEvent.pickupSuccess:
        showCustomSnackBar(context, "Trip started successfully");
        break;

      case TripEvent.showPayment:
        final tripRef =
            FirebaseFirestore.instance.collection("trip_req").doc(trip.TripId);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DriverFareCollectionPage(
              fare_amount: trip.FareAmount,
              trip_req_ref: tripRef,
            ),
          ),
        );
        break;

      case TripEvent.forceEndRequired:
        final user = ref.read(userProvider)!;
        final pos = ref.read(tripControllerProvider).position!;

        showDialog(
          context: context,
          builder: (_) => DriverEarlyEndDialog(
            TripId: trip.TripId,
            vehicleType: user.vehicleType!,
            pickUpLat: trip.PickUpLatLng.latitude,
            pickUpLng: trip.PickUpLatLng.longitude,
            dropLat: pos.latitude,
            dropLng: pos.longitude,
          ),
        );
        break;

      case TripEvent.overLimit:
        showCustomSnackBar(context, "get_closer_to_pickup_point".tr());
        break;

      case TripEvent.error:
        showCustomSnackBar(context, "something_went_wrong".tr());
        break;

      default:
        break;
    }
  }

  Future<void> _handlePrimaryAction() async {
    final trip = ref.read(tripDetailsProvider);
    if (trip == null) return;

    final controller = ref.read(tripControllerProvider.notifier);
    final status = ref.read(tripControllerProvider).status;

    TripEvent event;

    switch (status) {
      case "accepted":
        event = await controller.markArrived(trip);
        break;

      case "arrived":
        final verified = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DriverStartOtpPage(otp: trip.Otp),
          ),
        );
        if (verified == true) {
          event = await controller.markPickedUp(trip);
        } else {
          showCustomSnackBar(context, "OTP verification failed");
          return;
        }
        break;

      case "picked_up":
        event = await controller.endTrip(trip);
        break;

      default:
        return;
    }

    _handleEvent(event);
  }

  void _openGoogleMapsNavigation(TripDetailsModel trip) async {
    final state = ref.read(tripControllerProvider);
    final isFirstRoute = state.isFirstRoute;

    final lat =
        isFirstRoute ? trip.PickUpLatLng.latitude : trip.DropOffLatLng.latitude;
    final lng = isFirstRoute
        ? trip.PickUpLatLng.longitude
        : trip.DropOffLatLng.longitude;

    final Uri googleMapsUri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else {
      if (mounted) {
        showCustomSnackBar(context, "Could not open Google Maps");
      }
    }
  }

  void _showMoreOptionsSheet(TripDetailsModel trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Themes.white0,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "more_options".tr(),
                style: Themes.headline3.copyWith(fontSize: 18.sp),
              ),
              SizedBox(height: 16.h),
              customButton(
                text: "cancel_ride".tr(),
                backgroundColor: Colors.redAccent,
                textStyle: Themes.buttonText.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => DriverCancelDialog(
                      tripDetailsModel: trip,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(
      tripControllerProvider.select((state) => state.status),
      (previous, next) {
        if (next == 'cancelledByUser') {
          _handleCancellation();
        }
      },
    );
    ref.watch(tripControllerProvider
        .select((s) => s.isLoading)); // Rebuild on loading changes
    return Scaffold(
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════
          // GOOGLE MAP (Only rebuilds when markers change)
          // ═══════════════════════════════════════════════════
          Consumer(
            builder: (context, ref, child) {
              final markers = ref.watch(markerSetNotifierProvider);
              return GoogleMap(
                mapType: MapType.normal,
                myLocationEnabled: true,
                markers: markers,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(9.7131, 76.6833),
                  zoom: 14.0,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  ref.read(googleMapControllerProvider.notifier).state =
                      controller;
                },
              );
            },
          ),

          // ═══════════════════════════════════════════════════
          // TRIP INFO BOTTOM SHEET
          // ═══════════════════════════════════════════════════
          DraggableScrollableSheet(
            initialChildSize: 0.37,
            minChildSize: 0.2,
            maxChildSize: 0.6,
            builder: (BuildContext context, ScrollController scrollController) {
              return Column(
                children: [
                  // ─────────────────────────────────────────────
                  // NAVIGATION BUTTON (Only rebuilds when trip changes)
                  // ─────────────────────────────────────────────
                  Consumer(
                    builder: (context, ref, child) {
                      final trip = ref.watch(tripDetailsProvider);
                      if (trip == null) return const SizedBox.shrink();

                      return Container(
                        height: 50.h,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () => _openGoogleMapsNavigation(trip),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            elevation: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.navigation, color: Colors.white),
                              SizedBox(width: 8.w),
                              Text(
                                'navigation'.tr(),
                                style: Themes.smallButtonText.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 8.7.h),

                  // ─────────────────────────────────────────────
                  // MAIN BOTTOM SHEET CONTENT
                  // ─────────────────────────────────────────────
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final trip = ref.watch(tripDetailsProvider);

                        if (trip == null || trip.UserName == null) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Themes.white0,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.r),
                                topRight: Radius.circular(16.r),
                              ),
                              boxShadow: boxShadow(),
                            ),
                            child: Center(child: LoadingCircle(false)),
                          );
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: Themes.white0,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.r),
                              topRight: Radius.circular(16.r),
                            ),
                            boxShadow: boxShadow(),
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: EdgeInsets.all(16.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// 0. TRIP STATUS MESSAGE
                                Center(
                                  child: Text(
                                    "your_trip_has_started".tr(),
                                    style: Themes.headline2.copyWith(
                                      color: Themes.fire_red,
                                    ),
                                  ),
                                ),

                                /// LOADING INDICATOR (Only rebuilds when isLoading changes)
                                Consumer(
                                  builder: (context, ref, child) {
                                    final isLoading = ref.watch(
                                      tripControllerProvider
                                          .select((s) => s.isLoading),
                                    );
                                    if (!isLoading) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      child: LoadingLine(true),
                                    );
                                  },
                                ),

                                SizedBox(height: 4.h),
                                const Divider(color: Themes.gray1),
                                SizedBox(height: 4.h),

                                /// 1. CUSTOMER ROW WITH ICONS
                                _CustomerInfoRow(trip: trip),

                                SizedBox(height: 8.h),

                                /// 2. LOCATION DISPLAY
                                const _LocationDisplay(),

                                SizedBox(height: 8.h),

                                /// 3. SWIPE BUTTON
                                _ActionButton(
                                    onActionPressed: _handlePrimaryAction),

                                /// 4. MORE OPTIONS BUTTON
                                _MoreOptionsButton(
                                  onPressed: () => _showMoreOptionsSheet(trip),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CUSTOMER INFO ROW (Only rebuilds when trip details change)
// ═══════════════════════════════════════════════════════════════

class _CustomerInfoRow extends ConsumerWidget {
  final TripDetailsModel trip;

  const _CustomerInfoRow({required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Themes.white0,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: boxShadow(),
      ),
      child: Row(
        children: [
          /// Name (expandable but limited)
          Expanded(
            child: Text(
              trip.UserName ?? "customer".tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Themes.subtitlesubText.copyWith(
                color: Themes.black0,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          /// Message icon
          // GestureDetector(
          //   onTap: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(
          //         builder: (_) => ChatPage(
          //           rideId: ref.read(tripDetailsProvider)!.TripId,
          //           currentUserId: ref.read(userProvider)!.uid!,
          //           receiverId: ref.read(tripDetailsProvider)!.UserId,
          //         ),
          //       ),
          //     );
          //   },
          //   child: Padding(
          //     padding: EdgeInsets.only(left: 20.w),
          //     child: const Icon(Icons.message, color: Themes.gray3, size: 26),
          //   ),
          // ),
          /// Message icon
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    rideId: trip.TripId,
                    currentUserId: ref.read(userProvider)!.uid!,
                    receiverId: trip
                        .UserId, // 👈 fix: should be customer's ID, not driver's
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.message, color: Themes.gray3, size: 26),
                  ref
                              .watch(hasUnreadMessagesProvider((
                                rideId: trip.TripId,
                                currentUserId: ref.read(userProvider)!.uid!,
                              )))
                              .whenData((hasUnread) => hasUnread)
                              .value ==
                          true
                      ? Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),

          /// Call icon
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse("tel://${trip.UserPhone}"));
            },
            child: Padding(
              padding: EdgeInsets.only(left: 14.w),
              child: const Icon(Icons.phone, color: Themes.gray3, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LOCATION DISPLAY (Only rebuilds when isFirstRoute changes)
// ═══════════════════════════════════════════════════════════════

class _LocationDisplay extends ConsumerWidget {
  const _LocationDisplay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripDetailsProvider);
    final isFirstRoute = ref.watch(
      tripControllerProvider.select((s) => s.isFirstRoute),
    );

    if (trip == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Themes.white0,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: boxShadow(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, color: Themes.fire_red, size: 28),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              isFirstRoute ? trip.PickUpAddress : trip.DropOffAddress,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Themes.subtitlesubText.copyWith(
                color: Themes.black2,
                fontSize: 17.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ACTION BUTTON (Only rebuilds when status/loading changes)
// ═══════════════════════════════════════════════════════════════

class _ActionButton extends ConsumerWidget {
  final Future<void> Function() onActionPressed;

  const _ActionButton({required this.onActionPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      tripControllerProvider.select((s) => s.status),
    );
    final isLoading = ref.watch(
      tripControllerProvider.select((s) => s.isLoading),
    );

    return modernDriverSwipeButton(
      isLoading: isLoading,
      text: _getButtonText(status),
      onSubmit: onActionPressed,
      outerColor: _getButtonColor(status),
    );
  }

  String _getButtonText(String status) {
    switch (status) {
      case "accepted":
        return "arrived".tr();
      case "arrived":
        return "picked_up".tr();
      case "picked_up":
        return "end_trip".tr();
      default:
        return "";
    }
  }

  Color _getButtonColor(String status) {
    switch (status) {
      case "accepted":
        return Colors.indigoAccent;
      case "arrived":
        return Colors.green;
      case "picked_up":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// MORE OPTIONS BUTTON (Only rebuilds when moreOptionsEnabled changes)
// ═══════════════════════════════════════════════════════════════

class _MoreOptionsButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const _MoreOptionsButton({required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moreOptionsEnabled = ref.watch(
      tripControllerProvider.select((s) => s.moreOptionsEnabled),
    );

    if (!moreOptionsEnabled) return const SizedBox.shrink();

    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          "more_options".tr(),
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14.sp,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
