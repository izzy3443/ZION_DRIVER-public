import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/RAZORPAY-W&F/model_payment.dart';
import 'package:zion_driver_553/theme.dart';

class SubscriptionDetailsPage extends StatelessWidget {
  final SubscriptionHistory history;

  const SubscriptionDetailsPage({super.key, required this.history});

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color text;
    String statuslower;

    switch (status.toLowerCase()) {
      case "paid":
        statuslower = 'paid'.tr();
        bg = Themes.tree_green.withOpacity(0.15);
        text = Themes.tree_green;
        break;
      case "created":
        statuslower = 'created'.tr();
        bg = Themes.gray3.withOpacity(0.15);
        text = Themes.gray3;
        break;
      case "failed":
        statuslower = 'failed'.tr();
        bg = Themes.fire_red.withOpacity(0.15);
        text = Themes.fire_red;
        break;
      default:
        statuslower = 'created';
        bg = Themes.gray2.withOpacity(0.15);
        text = Themes.black0;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        statuslower.toUpperCase(),
        style: Themes.subtitlesubText.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.white1,
      appBar: AppBar(
        backgroundColor: Themes.white0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "subscription_details".tr(),
          style: Themes.headline2,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount
            // Amount
            Container(
              width: double.infinity, // full width
              padding: EdgeInsets.all(20.r),
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
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // center content horizontally
                children: [
                  Text("amount".tr(), style: Themes.SmallContainerText),
                  SizedBox(height: 8.h),
                  Text(
                    "₹${history.amount.toStringAsFixed(2)}",
                    style: Themes.headline3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Status + Currency
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(history.status),
                Text(
                  history.currency ?? "INR",
                  style: Themes.subtitlesubText,
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Dates
            Container(
              padding: EdgeInsets.all(20.r),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Created At
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("created_at".tr(), style: Themes.SmallContainerText),
                      Text(
                        _formatDate(history.createdAt),
                        style: Themes.bodyText1,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Expiry (nullable)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("expiry".tr(), style: Themes.SmallContainerText),
                      Text(
                        history.expiry != null
                            ? _formatDate(history.expiry!)
                            : "not_available".tr(),
                        style: Themes.bodyText1,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Contact Us Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Themes.fire_red,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  "contact_us_about_this".tr(),
                  style: Themes.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
