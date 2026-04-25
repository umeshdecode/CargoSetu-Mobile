import 'package:cargo_setu/util/constant.dart';
import 'package:cargo_setu/util/hex_code.dart';
import 'package:cargo_setu/util/strings.dart';
import 'package:flutter/material.dart';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get_storage/get_storage.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

class AppTheme {
  AppTheme._();
  static final GetStorage getStorage = GetStorage();

  static ThemeData light = lightTheme;
  static ThemeData dark = darkTheme;

  static const String appFontName = 'Lufga';

  static List<Color> get containerGradientColors {
    if (Get.isDarkMode) {
      return [
        HexColor("#121212"),
        // Deep matte black (better than pure #0D0D0D for OLED screens)
        HexColor("#1a1a24"),
        // Navy with subtle richness
        HexColor("#12122b"),
        // Softened dark slate (reduced harshness of #2F3542)
      ];
    } else {
      return [
        HexColor("#F0F8FF"),
        HexColor("#E1EBEE"),
        HexColor("#F9F9E0"),
      ];
    }
  }

  static List<Color> getQuotaCardColors(int index) {
    if (Get.isDarkMode) {
      switch (index) {
        case 0:
          return [Color(0xFF1E1E1E), Color(0xFF2A2A2A)]; // dark grey gradient
        case 1:
          return [Color(0xFF2B1A1A), Color(0xFF3A2222)]; // dark red tone
        case 2:
          return [Color(0xFF1A2B1D), Color(0xFF223A27)]; // dark green tone
        default:
          return [Color(0xFF1A1F2B), Color(0xFF222A3A)]; // dark blue tone
      }
    }
    switch (index) {
      case 0:
        return [Color(0xffD7F3F8), Color(0xffC4EBF0)]; // Total Quota
      case 1:
        return [Color(0xffFEE7E9), Color(0xffFAD6DA)]; // Used Quota
      case 2:
        return [Color(0xffE3F6E8), Color(0xffD0EBD8)]; // Unused Quota
      default:
        return [Color(0xffDCEBFF), Color(0xffC7DBFF)]; // Last Login / others
    }
  }

  static Color getBadgeColor(int index) {
    if (Get.isDarkMode) {
      switch (index % 4) {
        case 0:
          return Color(0xff1B4C57); // Dark teal
        case 1:
          return Color(0xff702020); // Dark red
        case 2:
          return Color(0xff164A22); // Dark green
        default:
          return Color(0xff1A2A62); // Dark blue
      }
    }
    switch (index % 4) {
      case 0:
        return Color(0xff0087A4); // teal
      case 1:
        return Color(0xffB61E1E); // red
      case 2:
        return Color(0xff0A7B28); // green
      default:
        return Color(0xff0A4FB7); // blue
    }
  }

  // Font Size

  static const double verySmall = 10;
  static const double small = 12;
  static const double medium = 15;
  static const double large = 18;
  static const double extraLarge = 22;
  static const double doubleExtraLarge = 24;
  static const double authTitle = 25.5;
  static const double authSubTitle = 16.5;
  static const double errorSize = 14;
  static const double errorSize2 = 16.8;

  static const double capSize = 16;
  static const double capSize1 = 14;
  static const double capSize2 = 15;
  static const double bodyText1 = 18;
  static const double bodyText2 = 18;
  static const double subtitle = 22;
  static const double title = 27;
  static const double title2 = 22;
  static const double headline = 32;
  static const double display = 42;

//
// Colors
//   static Color get colorPrimary => HexColor("#206aed");
//   static Color get colorPrimary {
//     String brand =
//         getStorage.read(Constant.selectedBrand) ?? getPackageName().toString();
//     return getBrandPrimaryColor(brand);
//   }

  static Color get colorPrimary => const Color(0xFF206aed);
  static Color get colorPrimaryTheme => const Color(0xFF206aed);
  static Color get colorAccentTheme => const Color(0xFF206aed);


  static Color get colorBackground =>
      Get.isDarkMode ? HexColor("#121212") : HexColor("#f5faff");

  static Color get colorPrimaryDark =>
      Get.isDarkMode ? HexColor("#A56400") : HexColor("#C76A0A");

  static Color get colorAccent =>
      Get.isDarkMode ? HexColor("#1A4ED6") : HexColor("#206aed");

  static Color get colorStatusBar =>
      Get.isDarkMode ? HexColor("#2E3C72") : HexColor("#6C92F4");

  static Color get colorTransparent => Colors.transparent;

  static Color get lightPrimary =>
      Get.isDarkMode ? HexColor("#B38F00") : HexColor('#F8BD0A');

  static Color colorBtnBg = HexColor('#A7E3A1');
  static Color colorBtnBgText = HexColor('#136A13');

  // static Color get colorPrimaryTheme {
  //   String brand =
  //       getStorage.read(Constant.selectedBrand) ?? getPackageName().toString();
  //   return getBrandPrimaryColor(brand);
  // }

  // static Color get colorAccentTheme {
  //   String brand =
  //       getStorage.read(Constant.selectedBrand) ?? getPackageName().toString();
  //   return getBrandPrimaryColor(brand);
  // }

  // Color colorPrimaryTheme =
  //     getBrandPrimaryColor(getStorage.read(Constant.selectedBrand));
  // Color colorAccentTheme =
  //     getBrandPrimaryColor(getStorage.read(Constant.selectedBrand));

  static Color get colorWhite => Get.isDarkMode ? Colors.black : Colors.white;

  // static Color colorBlack = HexColor("#000000");
  static Color get colorBlack => Get.isDarkMode ? Colors.white : Colors.black;
  static Color colorLightBlack = colorBlack.withOpacity(0.6);
  static Color colorIconGrey = HexColor("#999999");
  static Color colorGrey = HexColor("#8d8d8d");
  static Color colorLightGrey = HexColor("#E4E4E4");
  static Color colorDisableGray = HexColor("#ABABAB");
  static Color colorGrayTxtBg = HexColor('#E9E9E9');
  static Color colorGeenButton = HexColor('##41B314');

  static Color colorRed = HexColor("##D9534F");
  static Color colorBrightRed = Colors.red;
  static Color colorError = HexColor("#D32F2E");
  static Color colorGreen = HexColor("#2ED47A");
  static Color colorBrightGreen = Colors.green;

  static Color colorGreenRoundView = HexColor("#CCF6F2");
  static Color colorGreenRView = HexColor("1DC9B7");
  static Color colorBlueRoundView = HexColor("#E0F0FF");
  static Color colorBlueRView = HexColor("3A98F9");
  static Color colorLightBlue = HexColor("E1F5FE");
  static Color colorRedRoundView = HexColor("#FFE0EE");
  static Color colorRedRView = HexColor("FD3A95");
  static Color colorYellowRoundView = HexColor("#FFF4DE");
  static Color colorYellowRView = HexColor("#FBA908");

  static Color colorFilterBg = HexColor("#FFF6E4");

  static Color colorYellowStart = HexColor("#206aed");
  static Color colorYellowEnd = HexColor("#206aed");
  static Color colorYellowBtn = HexColor("#E7A008");

  static Color colorBlackStart = HexColor("#000000");
  static Color colorBlackEnd = HexColor("#212121");

  static Color colorProgress = HexColor("#F9E8C3");
  static Color colorProgressBg = HexColor("#206aed");

  static Color colorPositive = HexColor("#87BCBF");
  static Color colorNagative = HexColor("#D97D54");

  static Color dividerColor = HexColor("#707070");

  static Color statusUnAssignGray = HexColor('#666666');
  static Color statusAssignOrange = HexColor('#E69F08');
  static Color statusOnHold = HexColor('#F4516C');
  static Color statusClosedGreen = HexColor('#4B9D37');
  static Color buttonGreen = HexColor('#689f38');

  static Color statusPending = HexColor('#17A2B8');
  static Color statusApprove = HexColor('#28A745');
  static Color statusReject = HexColor('#DC3545');

  // static Color statusRed = HexColor('#717171');

  static Color typeIssue = HexColor('#F4516C');
  static Color typeInquiry = HexColor('#E69F08');
  static Color typeRequest = HexColor('#4B9D37');

  // static Color colorBG = HexColor('#F0F3F4');
  static Color get colorBG =>
      Get.isDarkMode ? Colors.black : HexColor('#F0F3F4');

  static Color get title_dark =>
      Get.isDarkMode ? Colors.white : HexColor('#334856');

  static Color get title_light =>
      Get.isDarkMode ? HexColor('#334856') : Colors.white;

  // static Color title_dark = HexColor('#334856');asda
  static Color lable_noramal = HexColor('#899095');
  static Color colorCardBtn = HexColor("#F6F6F6");
  static Color colorCardBg = HexColor("#FBFCFC");

  static Color useCardBg = HexColor("#DEF1C2");
  static Color unUseCardBg = HexColor("#FFE9C0");
  static Color totalCardBg = HexColor("#CAEAFF");
  static Color expantableItemBg = HexColor('#F8F8F8');

  static Color onlineStatusBg = HexColor("#28A745");
  static Color offlineStatusBg = HexColor("#EEEFF0");

  static Color custEditLight = HexColor("#E9FFE1");
  static Color custEditDark = HexColor("#61D88A");
  static Color custDeleteLight = HexColor("#FDF1EF");
  static Color custDeleteDark = HexColor("#F54535");
  static Color custUploadFileLight = HexColor("#E4F9FF");
  static Color custUploadFileDark = HexColor("#52ADF2");
  static Color custNearLocationLight = HexColor("#E6EDC4");
  static Color custNearLocationDark = HexColor("#9E9413");
  static Color custPaymentLinkLight = HexColor("#FFEBB9");
  static Color custPaymentLinkDark = HexColor("#F5B239");
  static Color custAssignInventoryLight = HexColor("#DEE0FA");
  static Color custAssignInventoryDark = HexColor("#4863C4");
  static Color custChangeStatusLight = HexColor("#FFE7D4");
  static Color custChangeStatusDark = HexColor("#EBA282");

  static Color colorCardWhiteBtn = HexColor("#FBE7E2");

  static TextTheme textTheme = const TextTheme(
    // headline4: display1,
    // headline5: headline1,
    // headline6: title1,
    // subtitle2: subtitle1,
    // bodyText2: body2,
    // bodyText1: body1,
    // caption: caption,
    headlineMedium: display1,
    headlineSmall: headline1,
    titleLarge: title1,
    titleMedium: subtitle1,
    bodyLarge: body2,
    bodyMedium: body1,
    bodySmall: caption,
  );

  static TextStyle textStyle(
      {fontWeight = FontWeight.normal,
        fontSize = medium,
        color = Colors.black}) {
    return TextStyle(
        fontFamily: appFontName,
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color,
        height: 1);
  }

  static const TextStyle display1 = TextStyle(
    // h4 -> display1
    fontFamily: appFontName,
    fontWeight: FontWeight.normal,
    fontSize: display,
  );

  static const TextStyle headline1 = TextStyle(
    // h5 -> headline
    fontFamily: appFontName,
    fontWeight: FontWeight.normal,
    fontSize: headline,
  );

  static const TextStyle title1 = TextStyle(
    // h6 -> title
    fontFamily: appFontName,
    fontWeight: FontWeight.normal,
    fontSize: title,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontFamily: appFontName,
    fontWeight: FontWeight.normal,
    fontSize: subtitle,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: appFontName,
    fontWeight: FontWeight.bold,
    fontSize: bodyText2,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: appFontName,
    fontWeight: FontWeight.normal,
    fontSize: bodyText1,
  );

  static const TextStyle caption = TextStyle(
    // Caption -> caption
    fontFamily: appFontName,
    fontWeight: FontWeight.normal,
    fontSize: capSize1,
  );

  // dropdown text style
  static TextStyle dropdownTextStyle = TextStyle(
    color: AppTheme.colorBlack,
    fontSize: AppTheme.large,
    fontWeight: FontWeight.w400,
    height: 1,
    fontFamily: AppTheme.appFontName,
    decoration: TextDecoration.none,
  );

  // dropdown error style
  static TextStyle dropdownErrorStyle = TextStyle(
    color: AppTheme.colorError,
    fontWeight: FontWeight.normal,
    fontSize: AppTheme.errorSize2,
  );

  // dropdown label style
  static TextStyle dropdownLabelStyle = TextStyle(
    color: AppTheme.colorBlack,
    fontSize: AppTheme.large,
    fontWeight: FontWeight.normal,
    height: 1,
    fontFamily: AppTheme.appFontName,
    decoration: TextDecoration.none,
  );

  // dropdown hint style
  static TextStyle dropdownHintStyle = TextStyle(
    fontSize: AppTheme.large,
    fontWeight: FontWeight.normal,
    height: 1,
    color: AppTheme.colorIconGrey,
    fontFamily: AppTheme.appFontName,
    decoration: TextDecoration.none,
  );
}

Color getBrandPrimaryColor(String brand) {
  switch (brand) {
    case "HTI":
      return const Color(0xFF00AEEF);
    case "TuTu":
      return const Color(0xFFF48042);
    case "Ananda":
      return const Color(0xFF206aed);
    default:
      return const Color(0xFFFE3006); // Vnet
  }
}


