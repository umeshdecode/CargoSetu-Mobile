import 'package:cargo_setu/util/resources.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'constant.dart';

GetStorage getStorage = GetStorage();

String getAppNamePre(String brand) {
  switch (brand) {
    case "HTI":
      return "HTI";
    case "TuTu":
      return "TuTu";
    case "Vnet":
      return "Vnet";
    default:
      return "Ananda"; // Vnet
  }
}

Future<String> getPackageName() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  if (packageInfo.packageName.toString() == 'com.tretail.selfcare.mm' ||
      packageInfo.packageName.toString() == 'com.tretail.selfcare.mm.ios' ||
      packageInfo.packageName.toString() == 'com.ananda.selfcare.mm' ||
      packageInfo.packageName.toString() == 'com.ananda.selfcare.mm.ios') {
    if (packageInfo.packageName.toString() == 'com.tretail.selfcare.mm' ||
        packageInfo.packageName.toString() == 'com.tretail.selfcare.mm.ios') {
      getStorage.write(Constant.appIconPath, appIcon);
    } else {
      getStorage.write(Constant.appIconPath, anandaAppIcon);
    }
    return 'Ananda';
  } else if (packageInfo.packageName.toString() == 'com.hinet.selfcare.mm' ||
      packageInfo.packageName.toString() == 'com.hti.selfcare.mm') {
    getStorage.write(Constant.appIconPath, hiNetAppIcon);
    return 'HTI';
  } else if (packageInfo.packageName.toString() == 'com.vnet.selfcareapp.mm' ||
      packageInfo.packageName.toString() == 'com.vnet.selfcare.mm.ios') {
    getStorage.write(Constant.appIconPath, vnetAppIcon);
    return 'Vnet';
  } else if (packageInfo.packageName.toString() == 'com.tutu.selfcare.mm' ||
      packageInfo.packageName.toString() == 'com.tutu.selfcare.mm.ios') {
    getStorage.write(Constant.appIconPath, tutuAppIcon);
    return 'TuTu';
  } else {
    getStorage.write(Constant.appIconPath, anandaAppIcon);
    return 'Ananda';
  }
}