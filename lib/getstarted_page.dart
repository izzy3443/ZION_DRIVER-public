import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion_driver_553/pages/LOGIN_PAGE-W&F/screen_login.dart';
import 'package:zion_driver_553/theme.dart';
import 'package:zion_driver_553/pages/LOGIN_PAGE-W&F/screen_language.dart';

class GetstartedPage extends ConsumerWidget {
  const GetstartedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Themes.white0,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 5),

            // ZION
            Center(
              child: Text(
                'ZION',
                style: TextStyle(
                  fontFamily: 'outfit',
                  letterSpacing: -2.777,
                  fontSize: 49.sp,
                  fontWeight: FontWeight.w600,
                  color: Themes.fire_red,
                ),
              ),
            ),

            // RIDER
            Transform.translate(
              offset: const Offset(0, -8),
              child: Center(
                child: Text(
                  'RIDER',
                  style: Themes.headline4.copyWith(
                    fontFamily: 'outfit',
                    fontSize: 37.sp,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),

            const Spacer(flex: 3),

            // GET STARTED BUTTON
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(210, 50),
                backgroundColor: Themes.fire_red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return LanguageSelectionPage(
                        isToLogin: true,
                      );
                    },
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(8.0.r),
                child: Text(
                  'Get Started',
                  style: Themes.TextFieldMainText.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Themes.white0,
                  ),
                ),
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
