import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:zion_driver_553/firebase_options.dart';

Future<void> initializeFirebase() async {
  if (kIsWeb) {
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for web - '
      'you can reconfigure this by running the FlutterFire CLI again.',
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
