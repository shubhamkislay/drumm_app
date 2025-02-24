import 'package:drumm_app/core/util/debouncer_brightness.dart';
import 'package:drumm_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const Color DARK_BACKGROUND = Color(0xff080808);
const String DRUMM_FONT_FAMILY = "opensansmedium";

class DrummTheme{
   static ThemeData drummDarkTheme = ThemeData(
     fontFamily: DRUMM_FONT_FAMILY,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF0080FF), // Accent color
    scaffoldBackgroundColor:  primaryDarkBackgroundColor, // Background color
    appBarTheme:  AppBarTheme(
      backgroundColor: primaryDarkBackgroundColor,
      iconTheme: IconThemeData(color: Color(0xFFFFFFFF)),
      titleTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 16.0,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 14.0,
      ),
    ),
    cardColor:  primaryDarkItemColor, // Darker background for cards
    iconTheme: const IconThemeData(
      color: Color(0xFFFFFFFF),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0080FF), // Button background color
        foregroundColor: const Color(0xFFFFFFFF), // Button text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF0080FF), // TextButton color
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF0080FF), // OutlinedButton text color
        side: const BorderSide(color: Color(0xFF0080FF)), // OutlinedButton border color
      ),
    ),
    dividerColor: const Color(0xFFFFFFFF).withOpacity(0.5), // Divider color
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A1A1A), // Darker fill for inputs
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    ),
  );
   static ThemeData drummLightTheme = ThemeData(
    fontFamily: DRUMM_FONT_FAMILY,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF0080FF), // Accent color for the app
    scaffoldBackgroundColor: primaryLightBackgroundColor, // Background color
    appBarTheme: AppBarTheme(
      backgroundColor: primaryLightBackgroundColor,
      iconTheme: IconThemeData(color: Color(0xFF000000)),
      titleTextStyle: TextStyle(
        color: Color(0xFF000000),
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Color(0xFF000000),
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFF000000),
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF000000),
        fontSize: 16.0,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF000000),
        fontSize: 14.0,
      ),
    ),
    cardColor: const Color(0xFFF1F1F1), // Background for cards
    iconTheme: const IconThemeData(
      color: Color(0xFF000000),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0080FF), // Background color for ElevatedButton
        foregroundColor: const Color(0xFFFFFFFF), // Text color for ElevatedButton
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF0080FF), // Text color for TextButton
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF0080FF), // Text color for OutlinedButton
        side: const BorderSide(color: Color(0xFF0080FF)), // Border color
      ),
    ),
    dividerColor: const Color(0xFF000000).withOpacity(0.5), // Divider color
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F1F1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    ),
  );


   static Color drummPrimaryColor =  Color(0xFF0080FF);

       static Color primaryTextColorLight = Colors.black;
   static Color primaryLightBackgroundColor = Color(0xffe7e7e7);//Color(0xffF1F1F1);
   static Color primaryLightItemColor = Color(0xffffffff);// Color(0xffffffff);

   static Color primaryTextColorDark = Colors.white;
   static Color primaryDarkItemColor = Color(0xff1e1e1e);//Color(0xff111111);
   static Color primaryDarkBackgroundColor = Color(0xff000000);//Color(0xff080808);

   /*
   * themeModeNotifier.value = themeModeNotifier.value == ThemeMode.dark
    ? ThemeMode.light
    : ThemeMode.dark;
   *
   * */

  static ThemeData getTheme(BuildContext context){
    return isDarkMode(context) ? drummDarkTheme:drummLightTheme;
  }

  static ThemeData getDarkTheme(){
    return drummDarkTheme;
  }

  static ThemeData getLightTheme(){
    return drummLightTheme;
  }

  static Color primaryTextColor(BuildContext context){
    return isDarkMode(context) ? primaryTextColorDark:primaryTextColorLight;
  }

   static Color primarySelectedTextColor(BuildContext context){
     return isDarkMode(context) ? primaryTextColorLight:primaryTextColorDark;
   }

   static Color primaryItemColor(BuildContext context){
     return isDarkMode(context) ? primaryDarkItemColor:primaryLightItemColor;
   }

   static Color primarySelectedItemColor(BuildContext context){
     return isDarkMode(context) ? primaryLightItemColor:primaryDarkItemColor;
   }

   static Color primaryItemBackground(BuildContext context){
     return isDarkMode(context) ? primaryDarkBackgroundColor:primaryLightBackgroundColor;
   }

   static bool isDarkMode(BuildContext context){
    //return MediaQuery.of(context).platformBrightness == Brightness.dark;
     final stableBrightness = Provider.of<DebouncedBrightnessProvider>(context).stableBrightness;
     return stableBrightness == Brightness.dark;
   }

}

