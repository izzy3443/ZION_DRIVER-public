import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:zion_driver_553/UI/Activity_card.dart';
import 'package:zion_driver_553/UI/Loading_UI.dart';
import 'package:zion_driver_553/UI/smallUI.dart';
import 'package:zion_driver_553/pages/HOME_PAGE-W&F/screen_tripdetails.dart';
import 'package:zion_driver_553/theme.dart';

class DriverTripsHistoryPage extends ConsumerStatefulWidget {
  const DriverTripsHistoryPage({super.key});

  @override
  ConsumerState<DriverTripsHistoryPage> createState() =>
      _DriverTripsHistoryPageState();
}

class _DriverTripsHistoryPageState
    extends ConsumerState<DriverTripsHistoryPage> {
  String filter = "today".tr();
  final filters = ["today".tr(), "this_week".tr(), "this_month".tr()];
  final tripsProvider =
      StateProvider<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
    (ref) => [],
  );
  final isLoadingProvider = StateProvider.autoDispose<bool>((ref) => true);
  final totalEarningsProvider = StateProvider.autoDispose<double>((ref) => 0.0);
  final totalRidesProvider = StateProvider.autoDispose<int>((ref) => 0);
  @override
  void initState() {
    super.initState();
    _fetchTrips(); // Initial fetch
  }

  Future<void> _fetchTrips() async {
    ref.read(isLoadingProvider.notifier).state = true;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("User is not logged in.");
      ref.read(tripsProvider.notifier).state = [];
      ref.read(isLoadingProvider.notifier).state = false;
      return;
    }

    final uid = user.uid;
    DateTime now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (filter) {
      case "Today":
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case "This Week":
        start = now.subtract(Duration(days: now.weekday - 1)); // Monday
        start = DateTime(start.year, start.month, start.day);
        end = start
            .add(const Duration(days: 7))
            .subtract(const Duration(milliseconds: 1));
        break;
      case "This Month":
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(milliseconds: 1));
        break;
      default:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    }

    final snapshot = await FirebaseFirestore.instance
        .collection("trip_req")
        .where("DriverId", isEqualTo: uid)
        .where("Status", isEqualTo: "Paid")
        .where("StartTime", isGreaterThanOrEqualTo: start)
        .where("StartTime", isLessThanOrEqualTo: end)
        .orderBy("StartTime", descending: true)
        .get();
    final docs = snapshot.docs;
    ref.read(tripsProvider.notifier).state = docs;
    ref.read(totalEarningsProvider.notifier).state = docs.fold(
      0.0,
      (sum, doc) =>
          sum + (double.tryParse(doc['FareAmount'].toString()) ?? 0.0),
    );
    ref.read(totalRidesProvider.notifier).state = docs.length;
    ref.read(isLoadingProvider.notifier).state = false;
    ref.read(tripsProvider.notifier).state = snapshot.docs;
    ref.read(isLoadingProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final earnings = ref.watch(totalEarningsProvider);
    final rides = ref.watch(totalRidesProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("trip_history".tr()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0.w),
              child: _buildToggleButtons(),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0.w),
              child: Row(
                children: [
                  Expanded(
                    child: buildActivityCard(
                      title: 'earnings'.tr(),
                      value: "₹${earnings.toStringAsFixed(2)}",
                      subtitle: filter,
                      icon: Icons.account_balance_wallet_outlined,
                      color: const Color(0xFF303030),
                      textColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: buildActivityCard(
                      title: 'total_rides'.tr(),
                      value: "$rides",
                      subtitle: filter,
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFFFFF8E1),
                      textColor: Themes.black0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: isLoading
                  ? Center(child: LoadingCircle(false))
                  : trips.isEmpty
                      ? Center(child: Text("no_trips_found".tr()))
                      : ListView.builder(
                          itemCount: trips.length,
                          itemBuilder: (context, index) {
                            final trip = trips[index].data();
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0.w,
                              ),
                              child: reusableListItem(
                                icon: Icons.location_on_outlined,
                                title: trip['dropoff_address'] ??
                                    'Unknown Drop Location',
                                subtitle: _formatTimeRange(trip),
                                iconColor: Themes.fire_red,
                                trailing: Padding(
                                  padding: EdgeInsets.only(left: 8.w),
                                  child: Text(
                                    "₹${double.tryParse(trip['FareAmount'].toString())?.toStringAsFixed(2) ?? '0.00'}",
                                    style: Themes.buttonText.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Themes.black0),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TripDetailsScreen(
                                          ride: trip as Map<String, dynamic>),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeRange(Map<String, dynamic> trip) {
    final start = (trip["StartTime"] as Timestamp).toDate();
    return DateFormat('MMM d').format(start);
  }

  Widget _buildToggleButtons() {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(8.r),
      borderColor: Colors.grey.shade400,
      selectedBorderColor: Themes.fire_red,
      selectedColor: Themes.fire_red,
      fillColor: Themes.fire_red.withOpacity(0.1),
      isSelected: filters.map((f) => f == filter).toList(),
      onPressed: (index) {
        filter = filters[index];
        _fetchTrips();
      },
      children: filters
          .map((f) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Text(f),
              ))
          .toList(),
    );
  }
}
