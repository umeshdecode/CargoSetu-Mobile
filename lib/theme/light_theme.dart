import 'package:flutter/material.dart';

import 'app_theme.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: AppTheme.colorPrimaryTheme,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  appBarTheme: AppBarTheme(
    color: AppTheme.colorPrimaryTheme,
    elevation: 0,
    toolbarTextStyle: ThemeData.light().textTheme.titleLarge!,
    titleTextStyle: TextStyle(fontSize: 20, color: AppTheme.colorWhite),
    // textTheme: TextTheme(
    //   headline6: TextStyle(
    //     color: AppTheme.colorWhite,
    //     fontSize: 20,
    //   ),
    // ),
  ),
  colorScheme:
      ColorScheme.fromSwatch().copyWith(secondary: AppTheme.colorAccentTheme),
);
