import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  late RxBool isDarkMode;

  @override
  void onInit() {
    super.onInit();
    isDarkMode = RxBool(_box.read(_key) ?? false);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _box.write(_key, isDarkMode.value);

    Get.changeThemeMode(
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
