import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zion_driver_553/UI/snackBar.dart';
import 'package:zion_driver_553/RAZORPAY-W&F/PaymentApi.dart';
import 'package:zion_driver_553/RAZORPAY-W&F/model_payment.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/theme.dart';
import 'package:zion_driver_553/providers/provider_user.dart';

final isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class RazorpayController {
  final PaymentsApi api;
  final _razorpay = Razorpay();
  final BuildContext context;
  final WidgetRef ref;

  RazorpayController(
      {required this.api, required this.context, required this.ref}) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  Future<void> buySku(String sku) async {
    try {
      ref.read(isLoadingProvider.notifier).update((state) => true);
      final order = await api.createOrderSecure(sku);

      // Get current app language (from easy_localization)
      final langCode = context.locale.languageCode;

      final options = {
        'key': order.keyId,
        'amount': order.amount,
        'currency': order.currency,
        'name': order.name,
        'description': 'Order ${order.orderId}',
        'order_id': order.orderId,
        'retry': {'enabled': true, 'max_count': 1},
        'theme': {'color': '#0f172a'},

        // Payment methods
        'method': {
          'upi': true,
          'card': true,
          'netbanking': true,
          'wallet': true,
        },
        'upi': {
          'flow': 'intent',
        },

        // 👇 Add language config for Razorpay checkout
        'config': {
          'display': {
            'language': langCode // en, hi, or te
          }
        }
      };

      ref.read(isLoadingProvider.notifier).state = false;
      _razorpay.open(options);
    } catch (e) {
      showCustomSnackBar(context, "error_initiating_payment".tr());
    }
  }

  Future<void> _onSuccess(PaymentSuccessResponse r) async {
    try {
      ref.read(isLoadingProvider.notifier).state = true;
      final verified = await api.verify(
        orderId: r.orderId!,
        paymentId: r.paymentId!,
        signature: r.signature!,
      );
      if (verified) {
        ref.invalidate(subscriptionHistoryProvider);
        await _checkSubscription();

        showCustomSnackBar(context, "payment_successful".tr(),
            backgroundColor: Themes.tree_green);
      } else {
        showCustomSnackBar(context, "payment_verification_failed".tr(),
            backgroundColor: Themes.fire_red);
      }
    } catch (e) {
      showCustomSnackBar(context, "payment_verification_failed".tr(),
          backgroundColor: Themes.fire_red);
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  void _onError(PaymentFailureResponse r) {
    final msg = switch (r.code) {
      Razorpay.PAYMENT_CANCELLED => "payment_cancelled_by_user".tr(),
      Razorpay.NETWORK_ERROR => "no_internet_connection".tr(),
      Razorpay.INVALID_OPTIONS => "invalid_payment_options".tr(),
      _ => r.message ?? "payment_failed".tr(),
    };
    showCustomSnackBar(context, msg, backgroundColor: Themes.fire_red);
  }

  void _onExternalWallet(ExternalWalletResponse r) {}

  void dispose() {
    _razorpay.clear();
  }

  Future<void> _checkSubscription() async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable("checkSubscription")
          .call({'uid': ref.read(userProvider)!.uid});

      final expiry = DateTime.parse(result.data['expiry']);
      final active = result.data['active'] as bool;

      ref
          .read(userProvider.notifier)
          .updateSubscription(expiry: expiry, active: active);
    } on FirebaseFunctionsException catch (e) {
      debugPrint("❌  Function failed");
      rethrow;
    } catch (e) {
      debugPrint("❌ Unknown error in subscriptionCheck: ");
      rethrow;
    }
  }
}
