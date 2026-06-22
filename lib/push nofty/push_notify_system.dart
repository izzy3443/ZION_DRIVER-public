import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotifySystem {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> generateNotificationToken() async {
    // Generate the notification token
    String? deviceNotificationToken = await firebaseMessaging.getToken();

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null && deviceNotificationToken != null) {
      await _firestore
          .collection("drivers")
          .doc(currentUser.uid)
          .update({"deviceToken": deviceNotificationToken});
      await firebaseMessaging.subscribeToTopic("drivers");
    }
  }
}
