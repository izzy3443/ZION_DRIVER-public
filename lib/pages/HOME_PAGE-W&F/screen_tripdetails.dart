import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/smallUI.dart';
import 'package:zion_driver_553/theme.dart';

class TripDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> ride;

  const TripDetailsScreen({Key? key, required this.ride}) : super(key: key);

  String getTripDurationFormatted(Map<String, dynamic> ride) {
    final start = ride['StartTime'];
    final end = ride['EndTime'];

    if (start is! Timestamp) return 'Invalid start time';
    if (end is! Timestamp) return 'Trip end not recorded';

    final startTime = start.toDate();
    final endTime = end.toDate();

    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hr${minutes > 0 ? ' $minutes min' : ''}';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.white0,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _driverWelcomeContainer(),
              SizedBox(height: 16.h),
              _buildLocationContainer(),
              SizedBox(height: 16.h),
              _buildTripTimeCard(),
              SizedBox(height: 16.h),
              _buildPaymentAndAmountRow(),
              SizedBox(height: 16.h),
              _buildVehicleAndStatsRow(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationContainer() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: _createGradientBox(
        colors: [Themes.black3, Themes.black2],
      ),
      child: Column(
        children: [
          _buildLocationRow(
            icon: Icons.location_on_outlined,
            title: 'pickup_location'.tr(),
            address: ride['pickup_address'] ?? 'Unknown pickup location',
            color: Themes.tree_green,
          ),
          SizedBox(height: 20.h),
          const Divider(),
          SizedBox(height: 20.h),
          _buildLocationRow(
            icon: Icons.location_on_outlined,
            title: 'drop_location'.tr(),
            address: ride['dropoff_address'] ?? 'Unknown dropoff location',
            color: Themes.fire_red,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String title,
    required String address,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'outfit',
                  color: Themes.white0.withOpacity(0.7),
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                address,
                style: TextStyle(
                  fontFamily: 'outfit',
                  color: Themes.white0,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _driverWelcomeContainer() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: boxShadow(),
      ),
      child: Row(
        children: [
          _buildDriverAvatar(),
          SizedBox(width: 16.w),
          _buildDriverInfo(),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }

  Widget _buildDriverAvatar() {
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 2.w),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.r),
        child: Image.network(
          ride['DriverPhoto'] ??
              'https://images.unsplash.com/photo-1633332755192-727a05c4013d?w=100&q=80',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'you'.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            ride['DriverName'] ?? 'Unknown Driver',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Themes.black0, size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Themes.black0, size: 22),
          onPressed: () {},
        ),
      ],
    );
  }

  BoxDecoration _createGradientBox({required List<Color> colors}) {
    return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: boxShadow());
  }

  Widget _buildTripTimeCard() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Themes.white0,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Themes.fire_red.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTripDurationHeader(),
          SizedBox(height: 20.h),
          _buildStartEndTimeRow(),
        ],
      ),
    );
  }

  Widget _buildTripDurationHeader() {
    final durationText = getTripDurationFormatted(ride); // calling the function

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'trip_duration'.tr(),
          style: TextStyle(
            fontFamily: 'outfit',
            color: Colors.black54,
            fontSize: 14.sp,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Themes.black0.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            durationText,
            style: TextStyle(
              fontFamily: 'outfit',
              color: Themes.black0,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartEndTimeRow() {
    final start = ride['StartTime'];
    final end = ride['EndTime'];

    final startTime = start is Timestamp ? start.toDate() : null;
    final endTime = end is Timestamp ? end.toDate() : null;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('started'.tr(), style: Themes.SmallContainerText),
              SizedBox(height: 8.h),
              Text(
                startTime != null
                    ? DateFormat('h:mm a').format(startTime)
                    : 'N/A',
                style: Themes.headline3,
              ),
            ],
          ),
        ),
        Container(
          width: 1.w,
          height: 40.h,
          color: Colors.black.withOpacity(0.2),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ended'.tr(), style: Themes.SmallContainerText),
                SizedBox(height: 8.h),
                Text(
                  endTime != null
                      ? DateFormat('h:mm a').format(endTime)
                      : 'Not ended',
                  style: Themes.headline3,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentAndAmountRow() {
    final fareAmount = _parseFareAmount();

    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.credit_card,
            label: 'payment'.tr(),
            value: ride['PaymentMethod'] ?? 'Cash',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.receipt_outlined,
            label: 'amount'.tr(),
            value: '₹$fareAmount',
          ),
        ),
      ],
    );
  }

  String _parseFareAmount() {
    try {
      final rawFare = ride['FareAmount'] ?? '0';
      final double fare = double.parse(rawFare.toString());
      return fare.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  Widget _buildVehicleAndStatsRow() {
    final vehicleType = (ride['VehicleType'] ?? '').toString();

    final double? distance =
        ride['Distance'] is num ? ride['Distance'].toDouble() : null;
    final distanceDisplay =
        distance != null ? distance.toStringAsFixed(distance < 1 ? 1 : 0) : '-';
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon:
                vehicleType == 'bike' ? Icons.motorcycle : Icons.directions_car,
            label: 'vehicle'.tr(),
            value: ride['VehicleDetails'] ?? 'Unknown',
            subtitle: ride['VehicleNumberPlate'] ?? 'Unknown',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.route,
            label: 'Distance',
            value: distanceDisplay,
            subtitle: 'km',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Themes.white0,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: boxShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Themes.selected_red,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: Themes.fire_red, size: 20),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'outfit',
              color: Themes.gray3,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'outfit',
              color: Themes.black0,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'outfit',
                color: Themes.gray3,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
