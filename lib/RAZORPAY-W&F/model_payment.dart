import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/providers/provider_user.dart';

class SubscriptionHistory {
  final double amount; // in rupees now
  final String status;
  final DateTime createdAt;
  final DateTime? expiry; // nullable
  final String orderId;
  final String? paymentId;
  final String? currency;
  final String? sku;

  SubscriptionHistory({
    required this.amount,
    required this.status,
    required this.createdAt,
    this.expiry,
    required this.orderId,
    this.paymentId,
    this.currency,
    this.sku,
  });

  factory SubscriptionHistory.fromMap(Map<String, dynamic> map) {
    return SubscriptionHistory(
      amount: ((map['amount'] ?? 0) as num).toDouble() / 100, // paise → rupees
      status: map['status'] ?? "unknown",
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiry:
          map['expiry'] != null ? (map['expiry'] as Timestamp).toDate() : null,
      orderId: map['orderId'] ?? "",
      paymentId: map['paymentId'],
      currency: map['currency'],
      sku: map['sku'],
    );
  }
}

final subscriptionHistoryProvider =
    FutureProvider<List<SubscriptionHistory>>((ref) async {
  final uid = ref.read(userProvider)?.uid;
  if (uid == null) return [];

  final snap = await FirebaseFirestore.instance
      .collection("subscriptions")
      .doc(uid)
      .collection("history")
      .orderBy("createdAt", descending: true) // latest first
      .get();

  return snap.docs.map((doc) {
    final data = doc.data();
    return SubscriptionHistory.fromMap(data);
  }).toList();
});
