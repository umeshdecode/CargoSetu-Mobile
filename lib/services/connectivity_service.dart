import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';

/// Lightweight connectivity check service.
///
/// Uses a raw socket connection to Google DNS (8.8.8.8:53) to verify
/// internet reachability. No extra packages needed.
class ConnectivityService extends GetxService {
  final RxBool isConnected = true.obs;

  /// Check if device has internet access.
  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected.value = true;
        return true;
      }
    } on SocketException catch (_) {
      log('⚠️ No internet connection');
    } on TimeoutException catch (_) {
      log('⚠️ Internet check timed out');
    } catch (e) {
      log('⚠️ Connectivity check error: $e');
    }

    isConnected.value = false;
    return false;
  }
}
