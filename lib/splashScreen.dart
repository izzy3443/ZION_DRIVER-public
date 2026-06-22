import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/UI/Loading_UI.dart';
import 'package:zion_driver_553/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.white0,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3), // Push content down

            // App Name "ZION"
            Center(
              child: Text(
                'ZION',
                style: TextStyle(
                  fontFamily: 'opensanhebreww',
                  letterSpacing: -3.777,
                  fontSize: 74.sp,
                  fontWeight: FontWeight.bold,
                  color: Themes.fire_red,
                ),
              ),
            ),

            // Text "RIDER" right below "ZION" using the original design
            Transform.translate(
              offset: const Offset(0, -30),
              child: Center(
                child: Text(
                  "RIDER",
                  style: TextStyle(
                    color: Themes.black0,
                    fontSize: 54.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: "outfit",
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            const Spacer(flex: 2), // Push loading indicator further down

            // Loading Indicator
            LoadingCircle(false),

            const Spacer(flex: 1), // Add bottom spacing
          ],
        ),
      ),
    );
  }
}
