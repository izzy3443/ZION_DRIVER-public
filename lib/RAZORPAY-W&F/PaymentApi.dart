import 'package:cloud_functions/cloud_functions.dart';

class PaymentsApi {
  final _functions = FirebaseFunctions.instance;

  Future<CreateOrderResp> createOrderSecure(String sku) async {
    final callable = _functions.httpsCallable('createRazorpayOrder');
    final res = await callable.call({'sku': sku});
    final map = Map<String, dynamic>.from(res.data as Map);
    return CreateOrderResp(
      orderId: map['orderId'],
      amount: map['amount'], // in paise
      currency: map['currency'],
      keyId: map['keyId'], // public
      name: map['name'],
    );
  }

  Future<bool> verify({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final callable = _functions.httpsCallable('verifyRazorpaySign');
    final res = await callable.call({
      'orderId': orderId,
      'paymentId': paymentId,
      'signature': signature,
    });
    final map = Map<String, dynamic>.from(res.data as Map);
    return map['verified'] == true;
  }
}

class CreateOrderResp {
  final String orderId;
  final int amount; // paise
  final String currency;
  final String keyId;
  final String name;
  CreateOrderResp({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
    required this.name,
  });
}
