import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion_driver_553/pages/CHAT_PAGE-W&F/screen_RideChat.dart';
import 'package:zion_driver_553/models/chat_model.dart';

Stream<List<ChatMessage>> getMessages(String rideId) {
  return FirebaseFirestore.instance
      .collection('trip_req')
      .doc(rideId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data())).toList());
}

final hasUnreadMessagesProvider =
    StreamProvider.family<bool, ({String rideId, String currentUserId})>(
  (ref, args) {
    return FirebaseFirestore.instance
        .collection('trip_req')
        .doc(args.rideId)
        .collection('messages')
        .where('readBy.${args.currentUserId}', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  },
);

Future<void> sendMessage(
  WidgetRef ref,
  String text,
  String currentUserId,
  String receiverId,
  String rideId,
) async {
  ref.read(isSendingLoadingProvider.notifier).state = true;
  final message = ChatMessage(
    senderId: currentUserId,
    text: text,
    timestamp: DateTime.now(),
    readBy: {
      currentUserId: true,
      receiverId: false, // 👈 Use real receiver UID here
    },
  );

  await FirebaseFirestore.instance
      .collection('trip_req')
      .doc(rideId)
      .collection('messages')
      .add(message.toMap());
  ref.read(isSendingLoadingProvider.notifier).state = false;
}

Future<void> markMessagesAsRead(String rideId, String currentUserId) async {
  final messages = await FirebaseFirestore.instance
      .collection('trip_req')
      .doc(rideId)
      .collection('messages')
      .where('readBy.$currentUserId', isEqualTo: false)
      .get();

  final batch = FirebaseFirestore.instance.batch();

  for (var doc in messages.docs) {
    batch.update(doc.reference, {
      'readBy.$currentUserId': true,
    });
  }

  await batch.commit();
}
