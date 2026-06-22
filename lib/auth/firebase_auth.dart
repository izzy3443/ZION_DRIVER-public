import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zion_driver_553/auth/error_firebase.dart';
import 'package:zion_driver_553/models/user_model.dart';
import 'package:zion_driver_553/pages/HOME_PAGE-W&F/screen_dashboard.dart';
import 'package:zion_driver_553/pages/LOGIN_PAGE-W&F/screen_login.dart';
import 'package:zion_driver_553/main.dart';
import 'package:zion_driver_553/pages/LOGIN_PAGE-W&F/screen_vehicle.dart';

import 'package:zion_driver_553/pages/LOGIN_PAGE-W&F/screen_otp.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/screen_doc_name.dart';

import 'package:zion_driver_553/providers/provider_user.dart';

final auth = FirebaseAuth.instance;
final authProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(auth);
});

class FirebaseAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuthService(this._auth);

  Future<void> phoneSignIn(
      BuildContext context, String phoneNumber, WidgetRef ref) async {
    try {
      // AUTO ENTRY
      // almost never runs
      await _auth.verifyPhoneNumber(
        phoneNumber:
            phoneNumber, //Calls Firebase to send an OTP to the given phone number.
        //If the OTP is auto-filled (like in Android), it signs in the user automatically.
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInAndCheckStatus(
              context,
              credential,
              //  phoneNumber,
              ref);
        },
        verificationFailed: (FirebaseAuthException e) {
          handleFirebaseAuthException(context, e);
        },
        // sends otp and pushs the otp page  then the onpressed function is called to check the otp with the firebase otp onces make sure it is right and give the credit
        codeSent: (String verificationId, int? resendToken) {
          ref.read(isButtonLoadingProvider.notifier).update((state) => false);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return OtpPage(
                  phoneNumber: phoneNumber,
                  verificationId: verificationId,
                );
              },
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {}
  }

  void onOtpPressedFunctions(
      context, String verificationId, otpController, ref) async {
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpController.text.trim(),
    );

    await _signInAndCheckStatus(
        context,
        credential,
        //  phoneNumber,
        ref);
    ref.read(isButtonLoadingOtpProvider.notifier).update((state) => false);
  }

  Future<void> _signInAndCheckStatus(
      BuildContext context, AuthCredential credential, WidgetRef ref) async {
    // Sign in and get user
    final User? user = await _signInWithCredential(credential, context);

    if (user == null) {
      return;
    }
    final String uid = user.uid;
    ref.read(userProvider.notifier).setUser(
          AppUser(
            uid: user.uid,
            phoneNo: user.phoneNumber,
          ),
        );
    final DocumentSnapshot? userDoc = await _getUserDocument(uid);

    // Handle user document
    if (userDoc == null) {
      print(
          "USER DOC IS NULL THIS NEEDS TO RUN CAUSE THERE IS NO USER IN THE DB");
      await _handleNewUser(user, ref);
      _logUserDetails(user);
      _navigateToAppropriateScreen(context, user, userDoc, ref);
    } else {
      print(
          "USER DOC IS NOT NULL THIS NEEDS TO RUN CAUSE THERE IS USER IN THE DB");
      _logUserDetails(user);
      _navigateToAppropriateScreen(context, user, userDoc, ref);
    }
  }

  // Handle the sign-in process
  Future<User?> _signInWithCredential(
      AuthCredential credential, BuildContext context) async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        return null;
      }
      return user;
    } on FirebaseAuthException catch (e) {
      handleFirebaseAuthException(context, e);
    }
  }

  // Get user document from Firestore
  Future<DocumentSnapshot?> _getUserDocument(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('drivers').doc(uid).get();
      if (docSnapshot.exists) {
        return docSnapshot;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Handle new user creation
  Future<void> _handleNewUser(User user, WidgetRef ref) async {
    await _createNewUserData(user);
  }

// not good to keep dontknow yet
  // Create new user data in Firestore
  Future<void> _createNewUserData(User user) async {
    //CLOUD MAY BE HELPS IG

    final Map<String, dynamic> userDataMap = {
      'Uid': user.uid,
      'firstName': user.displayName ?? '',
      'lastName': "",
      'PhoneNo': user.phoneNumber ?? '',
      'Email': user.email ?? "doesn't have email",
      'TripStatus': 'NONE',
      'BlockStatus': 'no',
      "Status": "NONE",
      "TotalEarning": 0.0,
      "TotalRides": 0,
      "Verified": false,
      "Rating": 5.0,
    };

    final userdocref = _firestore.collection('drivers').doc(user.uid);

    await userdocref.set(
      userDataMap,
      SetOptions(merge: true),
    );

    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('grantTrialSubscription');

      await callable.call(<String, dynamic>{
        'uid': user.uid,
      });
    } catch (e) {}

    // CollectionReference documentsRef =
    //     userdocref.collection('driver_documents');

    // List<String> docNames = [
    //   'DrivingLicence',
    //   'RegistrationCertificate',
    //   'ProfilePhoto'
    // ];

    // for (String docName in docNames) {
    //   await documentsRef.doc(docName).set({
    //     'Status': 'absent',
    //   });
    // }
  }

  Future<void> _navigateToAppropriateScreen(BuildContext context, User user,
      DocumentSnapshot? userDoc, WidgetRef ref) async {
    if (userDoc != null && userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;

      final firstName = userData['firstName'];

      if (firstName == null || firstName == '') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => VehicleSelectionPage()),
        );
      } else {
        ref.invalidate(userProvider);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DriverHomePage()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => VehicleSelectionPage()),
      );
    }
  }

  void _logUserDetails(User user) {}
}
