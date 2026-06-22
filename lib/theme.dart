import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Themes {
  // Color

  static const smtg = Color.fromRGBO(231, 230, 231, 1.0);
  static const white2 = Color.fromRGBO(232, 232, 237, 1.0);
  static const white3 = Color.fromRGBO(231, 230, 231, 1.0); // newly added color
  static const gray1 = Color.fromRGBO(205, 205, 205, 1.0);
  static const gray2 = Color.fromRGBO(185, 185, 185, 1.0);
  static const white0 = Color.fromRGBO(255, 255, 255, 1.0);
  static const white1 = Color.fromRGBO(245, 245, 245, 1.0);
  static const gray3 = Color.fromRGBO(145, 145, 145, 1.0);
  static const black1 = Color.fromRGBO(68, 68, 69, 1.0);
  static const black2 = Color.fromRGBO(22, 22, 23, 1.0);
  static const black3 = Color.fromRGBO(30, 30, 30, 1.0);
  static const black0 = Color.fromRGBO(0, 0, 0, 1.0);
  static const fire_red = Color.fromRGBO(230, 57, 70, 1.0);
  static const tree_green = Color.fromRGBO(50, 187, 120, 1.0);
  static const gray44 = Color.fromRGBO(132, 141, 151, 1.0);
  static const selected_red = Color(0xFFFFF5F5);

  // primary color
  static TextStyle TextFieldPlaceHolder = TextStyle(
    fontSize: 34.sp,
    fontFamily: 'outfit',
    color: Themes.gray3,
    fontWeight: FontWeight.w600,
  );
  static TextStyle TextFieldText = TextStyle(
    fontSize: 34.sp,
    fontFamily: 'outfit',
    color: Themes.black0,
    fontWeight: FontWeight.w600,
  );

  // Text Styles
  static TextStyle headline = TextStyle(
    fontFamily: 'outfit',
    fontSize: 28.sp,
    letterSpacing: -1.7,
    fontWeight: FontWeight.w500,
    color: black0,
  );
  static TextStyle headline2 = TextStyle(
    fontFamily: 'outfit',
    fontSize: 22.sp,
    letterSpacing: -1.0,
    fontWeight: FontWeight.w600,
    color: black0,
  );
  static TextStyle headline3 = TextStyle(
    fontFamily: 'outfit',
    fontSize: 24.sp,
    letterSpacing: -0.5,
    fontWeight: FontWeight.w600,
    color: black0,
  );
  static TextStyle headline4 = TextStyle(
    height: -0.0,
    fontWeight: FontWeight.w500,
    color: Themes.gray3,
    fontFamily: 'outfit',
    fontSize: 24.sp,
    letterSpacing: -0.5,
  );

  static TextStyle bodyText1 = TextStyle(
    fontFamily: 'outfit',
    fontSize: 16.sp,
    color: black0,
    fontWeight: FontWeight.w200,
  );

  static TextStyle buttonText = TextStyle(
    fontFamily: 'outfit',
    fontSize: 18.sp,
    color: white0,
  );
  static TextStyle subtitleText = TextStyle(
    fontFamily: 'outfit',
    fontSize: 20.sp,
    color: Themes.black0,
    fontWeight: FontWeight.w500,
  );
  static TextStyle subtitlesubText = TextStyle(
    fontFamily: 'outfit',
    fontSize: 16.sp,
    color: Themes.gray3,
    fontWeight: FontWeight.w500,
  );

  static TextStyle buttonTextlogin = TextStyle(
      fontFamily: 'outfit',
      fontSize: 16.sp,
      color: white0,
      fontWeight: FontWeight.w400);

  // Extra Text Styles
  static TextStyle subtitle = TextStyle(
    fontFamily: 'outfit',
    fontSize: 20.sp,
    color: black0,
  );

  static TextStyle smallButtonText = TextStyle(
    fontFamily: 'outfit',
    fontSize: 16.sp,
    color: black0,
  );
  static TextStyle headlinePro = TextStyle(
    fontFamily: 'outfit',
    fontSize: 32.sp,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w500,
    color: black0,
  );

  static TextStyle MidContainerText = TextStyle(
      fontFamily: 'outfit',
      fontSize: 17.sp,
      color: black0,
      fontWeight: FontWeight.w500);
  static TextStyle SmallContainerText = TextStyle(
      fontFamily: 'outfit',
      fontSize: 14.sp,
      color: Themes.gray3,
      fontWeight: FontWeight.w400);
  static TextStyle SuperSmallContainerText = TextStyle(
      fontFamily: 'outfit',
      fontSize: 12.sp,
      color: Themes.gray3,
      fontWeight: FontWeight.w400);
  static TextStyle TextFieldHintText = TextStyle(
      fontFamily: 'outfit',
      fontSize: 18.sp,
      color: Themes.gray3,
      fontWeight: FontWeight.w400);
  static TextStyle TextFieldMainText = TextStyle(
      fontFamily: 'outfit',
      fontSize: 18.sp,
      color: Themes.black0,
      fontWeight: FontWeight.w400);

  // Themes
  static var darkModeAppTheme = ThemeData.dark().copyWith(
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      // Set the custom font for labels
      selectedLabelStyle: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 8.sp, // Adjust font size if needed
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 8.sp, // Adjust font size if needed
      ),

      // Set the color for the selected item
      selectedItemColor: Colors.blue, // Change to your preferred color
      // Set the color for the unselected items
      unselectedItemColor: Colors.black, // Change to your preferred color
    ),
    scaffoldBackgroundColor: black0,
    cardColor: gray2,
    appBarTheme: const AppBarTheme(
      backgroundColor: black3,
      iconTheme: IconThemeData(
        color: white0,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: black3,
    ),
    primaryColor: Colors.red,
  );

  static var lightModeAppTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: white0,
    cardColor: gray2,
    appBarTheme: const AppBarTheme(
      backgroundColor: white0,
      elevation: 0,
      iconTheme: IconThemeData(
        color: black0,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: white0,
    ),
    primaryColor: Colors.red,
  );
}
