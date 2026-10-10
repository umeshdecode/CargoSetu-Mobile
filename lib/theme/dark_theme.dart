import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  useMaterial3: false,
  splashFactory: InkRipple.splashFactory,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  // backgroundColor: Colors.black,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    unselectedItemColor: Colors.white,
    selectedItemColor: Colors.yellow.shade800,
    elevation: 0,
  ),
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
  appBarTheme: AppBarTheme(
    color: Colors.black,
    elevation: 0,
    toolbarTextStyle: ThemeData.light().textTheme.titleLarge!,
    titleTextStyle: const TextStyle(fontSize: 20, color: Colors.white),
    // textTheme: TextTheme(
    //   headline6: TextStyle(
    //     color: Colors.white,
    //     fontSize: 20,
    //   ),
    // ),
  ),
);
