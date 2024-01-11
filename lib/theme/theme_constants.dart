import 'package:flutter/material.dart';

const int COLOR_PRIMARY_VAL = 0xff008cff;
const COLOR_ACCENT = Colors.blue;
const Color COLOR_PRIMARY_DARK = Color(0xff101010);
const APP_FONT_LIGHT = "sans-serif";//"poppinslight";//"robotolight";chakrapetchlight
const APP_FONT_MEDIUM = "sans-serif";//"poppinsmedium";//"robotomedium";chakrapetchmedium
const APP_FONT_BOLD = "sans-serif";//"poppinsbold";//"robotobold";chakrapetchbold
const DEFAULT_APP_IMAGE_URL = "https://firebasestorage.googleapis.com/v0/b/drummapp.appspot.com/o/asset_image%2Finvite.png?alt=media&token=413b3a09-dc1a-4858-b42e-fcf6517b8175";

MaterialColor mainAppColor = const MaterialColor(COLOR_PRIMARY_VAL, <int, Color>{
  50: Color(COLOR_PRIMARY_VAL),
  100: Color(COLOR_PRIMARY_VAL),
  200: Color(COLOR_PRIMARY_VAL),
  300: Color(COLOR_PRIMARY_VAL),
  400: Color(COLOR_PRIMARY_VAL),
  500: Color(COLOR_PRIMARY_VAL),
  600: Color(COLOR_PRIMARY_VAL),
  700: Color(COLOR_PRIMARY_VAL),
  800: Color(COLOR_PRIMARY_VAL),
  900: Color(COLOR_PRIMARY_VAL),
});

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,//grey.shade200,
  primarySwatch: mainAppColor,
  floatingActionButtonTheme:
      FloatingActionButtonThemeData(backgroundColor: COLOR_ACCENT),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0)),
    shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
    backgroundColor: MaterialStateProperty.all<Color>(COLOR_ACCENT),
  )),
  textTheme: TextTheme(
    headlineMedium: TextStyle(fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontWeight: FontWeight.bold),
  ),
  inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(vertical: 16,horizontal: 24),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      filled: true,

      fillColor: Colors.grey.shade900.withOpacity(0.75)),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.grey.shade900,
  primarySwatch: mainAppColor,
  floatingActionButtonTheme:
      FloatingActionButtonThemeData(backgroundColor: COLOR_ACCENT),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0)),
    shape: MaterialStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
    backgroundColor: MaterialStateProperty.all<Color>(COLOR_ACCENT),
  )),
  textTheme: TextTheme(
    headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(vertical: 12,horizontal: 24),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.grey.shade900.withOpacity(0.75)),
);
