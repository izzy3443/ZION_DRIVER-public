import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/UI/Button.dart';
import 'package:zion_driver_553/UI/smallUI.dart';
import 'package:zion_driver_553/RAZORPAY-W&F/PaymentApi.dart';
import 'package:zion_driver_553/RAZORPAY-W&F/controller_subscription.dart';
import 'package:zion_driver_553/RAZORPAY-W&F/model_payment.dart';
import 'package:zion_driver_553/RAZORPAY-W&F/screen_subscription_details.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/models/user_model.dart';
import 'package:zion_driver_553/paths.dart';
import 'package:zion_driver_553/providers/provider_user.dart';
import 'package:zion_driver_553/theme.dart';

class PackageScreen extends ConsumerStatefulWidget {
  const PackageScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends ConsumerState<PackageScreen> {
  late final RazorpayController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        RazorpayController(api: PaymentsApi(), context: context, ref: ref);
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(subscriptionHistoryProvider);
    final user = ref.watch(userProvider)!;
    return Scaffold(
      backgroundColor: Themes.white0,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildPackageCard(user),
              _buildSubscriptionCard(user),
              historyAsync.when(
                data: (history) => _buildHistorySection(history),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text("failed_to_load_history".tr()),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(AppUser user) {
    final bool active = user.subscriptionActive!;

    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 25.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Themes.black2, Themes.black3],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Themes.black0.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "subscription".tr(),
                style: Themes.subtitleText.copyWith(
                  color: Themes.white0,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Themes.white0.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'ZION',
                  style: Themes.SuperSmallContainerText.copyWith(
                    letterSpacing: -0.7,
                    fontWeight: FontWeight.w600,
                    color: Themes.white0,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          Text(
            active ? "With Zion" : "ride_and_earn".tr(),
            style: Themes.subtitlesubText.copyWith(
              color: Themes.gray3,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),

          SizedBox(height: 12.h),

          Text(
            active ? "active".tr() : "inactive".tr(),
            style: Themes.buttonTextlogin.copyWith(
              fontSize: 36.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
              color: active ? Themes.tree_green : Themes.fire_red,
            ),
          ),

          SizedBox(height: 10.h),

          Text(
            _subscriptionText(ref.read(userProvider)),
            style: Themes.subtitlesubText.copyWith(
              color: Themes.gray3,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  String _subscriptionText(user) {
    if (user?.subscriptionExpiry == null) return "never_purchased".tr();
    return user!.subscriptionActive
        ? 'expires_on'
            .tr(namedArgs: {'date': formatDate(user.subscriptionExpiry!)})
        : 'expired_on'
            .tr(namedArgs: {'date': formatDate(user.subscriptionExpiry!)});
  }

  Widget _buildSubscriptionCard(AppUser user) {
    final bool Active = user.subscriptionActive!;
    // Map vehicle type to price & image
    final vehicleInfo = {
      "Car": {
        "type": "car_owner_package".tr(),
        "price": 899,
        "image": car_front, // your global asset
        "sku": "CAR_1M"
      },
      "Auto": {
        "type": "auto_owner_package".tr(),
        "price": 499,
        "image": auto_front,
        "sku": "AUTO_1M"
      }
    };

    final type = user.vehicleType; // from userProvider
    if (type == null || !vehicleInfo.containsKey(type)) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Text(
          "please_set_vehicle_type".tr(),
          style: Themes.subtitlesubText,
          textAlign: TextAlign.center,
        ),
      );
    }

    final price = vehicleInfo[type]!['price'] as int;
    final image = vehicleInfo[type]!['image'] as String;
    final typeText = vehicleInfo[type]!['type'] as String;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Themes.white0,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: boxShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.asset(
              image,
              width: 90.w,
              height: 90.h,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 12.h),

          // Vehicle Type
          Text(
            typeText,
            style: Themes.subtitleText.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 8.h),

          // Price
          Text(
            'price_per_month'.tr(namedArgs: {'price': price.toString()}),
            style: Themes.headline2.copyWith(
              color: Themes.tree_green,
            ),
          ),

          SizedBox(height: 20.h),
          // Buy Button
          // customButton(
          //   text: "buy_package".tr(),
          //   isLoading: ref.watch(isLoadingProvider),
          //   onPressed: () {
          //     _controller.buySku(vehicleInfo[type]!['sku'] as String);
          //   },
          // ),
          customButton(
            text: Active ? "already_active".tr() : "buy_package".tr(),
            isLoading: ref.watch(isLoadingProvider),
            textStyle: Themes.buttonText.copyWith(
              color: Active ? Themes.black2 : Themes.white0,
            ),
            onPressed: Active
                ? null
                : () {
                    _controller.buySku(vehicleInfo[type]!['sku'] as String);
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(List<SubscriptionHistory> history) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 25.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("package_history".tr(), style: Themes.headline2),
              Text(
                "All",
                style: Themes.subtitlesubText.copyWith(
                  color: Themes.fire_red,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...history.map((h) => _buildHistoryItem(h)).toList(),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(SubscriptionHistory h) {
    Color pillColor;
    Color pillTextColor;
    String pillText;

    switch (h.status.toLowerCase()) {
      case "paid":
        pillText = "Paid";
        pillColor = Themes.tree_green.withOpacity(0.15);
        pillTextColor = Themes.tree_green;
        break;
      case "failed":
        pillText = "Failed";
        pillColor = Themes.fire_red.withOpacity(0.15);
        pillTextColor = Themes.fire_red;
        break;
      default: // created or pending
        pillText = "Created";
        pillColor = Themes.black0.withOpacity(0.05);
        pillTextColor = Themes.black3;
    }

    final content = Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: Themes.white0,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Themes.black0.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long, color: Themes.black3),
          SizedBox(width: 12.w),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "₹${h.amount.toStringAsFixed(2)}",
                  style: Themes.subtitleText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),

                // Status pill
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    pillText.toUpperCase(),
                    style: Themes.subtitlesubText.copyWith(
                      color: pillTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Creation date
          Text(
            formatDate(h.createdAt),
            style: Themes.subtitlesubText.copyWith(fontSize: 12.sp),
          ),
        ],
      ),
    );

    // 👉 Wrap only if paymentId is not null
    if (h.paymentId != null) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SubscriptionDetailsPage(history: h),
            ),
          );
        },
        child: content,
      );
    } else {
      return content; // no navigation if paymentId is null
    }
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
