import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // 🔐 ADD
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zion_driver_553/auth/firebase_auth.dart';
import 'package:zion_driver_553/firebase_init_main/firebase_init.dart';
import "package:zion_driver_553/firebase_options.dart";
import 'package:zion_driver_553/getstarted_page.dart';
import 'package:zion_driver_553/models/user_model.dart';

import 'package:zion_driver_553/pages/HOME_PAGE-W&F/screen_dashboard.dart';
import 'package:zion_driver_553/pages/PERMISSION-W&F/controller_geo_permission.dart';
import 'package:zion_driver_553/pages/PERMISSION-W&F/controller_main_permission.dart';
import 'package:zion_driver_553/pages/SIGN_IN-W&F/screen_doc%20_main.dart';
import 'package:zion_driver_553/pages/LOGIN_PAGE-W&F/screen_vehicle.dart';
import 'package:zion_driver_553/providers/provider_user.dart';

import 'package:zion_driver_553/pages/PERMISSION-W&F/controller_notification_permission.dart';
import 'package:zion_driver_553/splashScreen.dart';
import 'package:zion_driver_553/pages/TRIP_REQ-W&F/kotlin_channel.dart';

/// 🔥 MAIN WITH CRASHLYTICS + APP CHECK
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupTripChannel();

  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// 🔐 APP CHECK (DEBUG MODE FOR DEVELOPMENT)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  /// 🔥 Enable Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  /// Catch Flutter errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  /// Catch async errors
  runZonedGuarded(() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLangCode = prefs.getString('languageCode');
    final startLocale = savedLangCode != null ? Locale(savedLangCode) : null;

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('te'), Locale('hi')],
        path: 'assets/translations',
        startLocale: startLocale,
        fallbackLocale: const Locale('en'),
        child: const ProviderScope(child: AppRoot()),
      ),
    );
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

/// Root with ScreenUtil
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const MyApp();
      },
    );
  }
}

/// Splash-aware Stateful App
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      await initializeFirebase();
      await requestLocationPermission();
      await requestNotificationPermission();

      setState(() => isLoading = false);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
    }
  }

  Widget authCheck() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const GetstartedPage();
    } else {
      FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
      return const DriverHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: isLoading ? const SplashScreen() : authCheck(),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
    );
  }
}
