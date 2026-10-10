import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cargo_setu/company/company_service.dart';
import 'package:cargo_setu/company/model/company_model.dart';
import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/services/session_service.dart';
import 'package:cargo_setu/util/constant.dart';
import 'package:cargo_setu/widgets/app_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Controller for company state and operations.
class CompanyController extends GetxController {
  final CompanyService _service = CompanyService();
  final GetStorage _storage = GetStorage();

  /// Current company data
  final Rx<CompanyModel?> currentCompany = Rx<CompanyModel?>(null);

  /// Whether user has a company
  final RxBool hasCompany = false.obs;

  /// Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedCompany();
  }

  /// Load cached company from GetStorage so UI is instantly populated without loading delay.
  void _loadCachedCompany() {
    final cachedStatus = _storage.read(Constant.companyStatus);
    if (cachedStatus != null) {
      hasCompany.value = cachedStatus == true || cachedStatus == 'true';
    }

    final cachedCompanyRaw = _storage.read(Constant.companyData);
    if (cachedCompanyRaw != null) {
      try {
        final Map<String, dynamic> json = cachedCompanyRaw is String
            ? jsonDecode(cachedCompanyRaw)
            : Map<String, dynamic>.from(cachedCompanyRaw as Map);
        currentCompany.value = CompanyModel.fromJson(json);
        hasCompany.value = true;
        log('📦 Loaded cached company: ${currentCompany.value?.companyName}');
      } catch (e) {
        log('⚠️ Error parsing cached company data: $e');
      }
    }
  }

  /// Fetch current user's company from API.
  Future<bool> fetchCurrentCompany() async {
    isLoading.value = true;
    try {
      final response = await _service.getCurrentCompany();
      final data = response.data;

      if (response.statusCode == 200 && data != null) {
        final responseCode = data['responseCode'];
        final dynamic rawCompanyData = data['data'] ??
            (data['dataList'] is List && (data['dataList'] as List).isNotEmpty
                ? (data['dataList'] as List).first
                : null);

        if ((responseCode == 200 || responseCode == null) &&
            rawCompanyData != null &&
            rawCompanyData is Map) {
          final map = Map<String, dynamic>.from(rawCompanyData);
          final model = CompanyModel.fromJson(map);

          currentCompany.value = model;
          hasCompany.value = true;

          _storage.write(Constant.companyStatus, true);
          _storage.write(Constant.companyData, jsonEncode(map));

          if (Get.isRegistered<SessionService>()) {
            Get.find<SessionService>().setCompanyStatus(true);
          }
          log('✅ Company loaded successfully: ${model.companyName}');
          return true;
        }
      }

      // No company found on server
      hasCompany.value = false;
      _storage.write(Constant.companyStatus, false);
      _storage.remove(Constant.companyData);

      if (Get.isRegistered<SessionService>()) {
        Get.find<SessionService>().setCompanyStatus(false);
      }
      return false;
    } on DioException catch (e) {
      log('❌ Fetch company error: ${e.response?.statusCode} ${e.response?.data}');
      // If we already have a cached company, keep it rather than blanking out
      if (currentCompany.value == null) {
        hasCompany.value = false;
        _storage.write(Constant.companyStatus, false);
      }
      return false;
    } catch (e) {
      log('❌ Fetch company unknown error: $e');
      if (currentCompany.value == null) {
        hasCompany.value = false;
        _storage.write(Constant.companyStatus, false);
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new company with optional logo file.
  Future<bool> createCompany(
    CompanyModel company, {
    File? logoFile,
    List<AssetUpload>? additionalAssets,
  }) async {
    isSubmitting.value = true;

    final assets = <AssetUpload>[];
    if (logoFile != null) {
      assets.add(AssetUpload(assetType: 'LOGO', file: logoFile));
    }
    if (additionalAssets != null) {
      assets.addAll(additionalAssets);
    }

    try {
      final formData = await company.toFormData(
        assetUploads: assets.isNotEmpty ? assets : null,
      );

      final response = await _service.createCompany(formData);
      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseCode = data['responseCode'];
        if (responseCode == 200 || responseCode == 201) {
          // Immediately apply returned company data
          final dynamic rawCreated = data['data'];
          if (rawCreated != null && rawCreated is Map) {
            final map = Map<String, dynamic>.from(rawCreated);
            currentCompany.value = CompanyModel.fromJson(map);
            hasCompany.value = true;
            _storage.write(Constant.companyStatus, true);
            _storage.write(Constant.companyData, jsonEncode(map));
          } else {
            currentCompany.value = company;
            hasCompany.value = true;
            _storage.write(Constant.companyStatus, true);
          }

          if (Get.isRegistered<SessionService>()) {
            Get.find<SessionService>().setCompanyStatus(true);
          }

          // Refresh JWT token to attach companyId to security session
          _refreshTokenAndSync();

          return true;
        } else {
          final msg = data['responseMessege'] ?? 'Failed to create company';
          AppSnackbar.error(msg);
          return false;
        }
      }

      AppSnackbar.error('Failed to create company');
      return false;
    } on DioException catch (e) {
      log('❌ Create company error: ${e.response?.statusCode} ${e.response?.data}');
      final data = e.response?.data;
      String msg = 'Failed to create company';
      if (data is Map) {
        msg = data['responseMessege'] ?? data['message'] ?? msg;
        if (e.response?.statusCode == 409) {
          msg = 'A company with this email already exists';
        }
      }
      AppSnackbar.error(msg);
      return false;
    } catch (e) {
      log('❌ Create company unknown error: $e');
      AppSnackbar.error(e.toString());
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Update existing company with optional new logo file.
  Future<bool> updateCompany(
    CompanyModel company, {
    File? logoFile,
    List<AssetUpload>? additionalAssets,
  }) async {
    isSubmitting.value = true;

    final assets = <AssetUpload>[];
    if (logoFile != null) {
      assets.add(AssetUpload(assetType: 'LOGO', file: logoFile));
    }
    if (additionalAssets != null) {
      assets.addAll(additionalAssets);
    }

    try {
      final formData = await company.toFormData(
        assetUploads: assets.isNotEmpty ? assets : null,
      );

      final response = await _service.updateCompany(formData);
      final data = response.data;

      if (response.statusCode == 200) {
        final responseCode = data['responseCode'];
        if (responseCode == 200 || responseCode == 201) {
          final dynamic rawUpdated = data['data'];
          if (rawUpdated != null && rawUpdated is Map) {
            final map = Map<String, dynamic>.from(rawUpdated);
            currentCompany.value = CompanyModel.fromJson(map);
            _storage.write(Constant.companyData, jsonEncode(map));
          } else {
            currentCompany.value = company;
          }

          _refreshTokenAndSync();
          return true;
        }
      }

      final msg = data?['responseMessege'] ?? 'Failed to update company';
      AppSnackbar.error(msg);
      return false;
    } on DioException catch (e) {
      log('❌ Update company error: ${e.response?.data}');
      final data = e.response?.data;
      final msg = (data is Map)
          ? (data['responseMessege'] ?? data['message'] ?? 'Failed to update')
          : 'Failed to update company';
      AppSnackbar.error(msg);
      return false;
    } catch (e) {
      log('❌ Update company unknown error: $e');
      AppSnackbar.error(e.toString());
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Refresh token in background and re-pull full company profile.
  void _refreshTokenAndSync() async {
    try {
      final refreshed = await ApiRequest().refreshToken();
      if (refreshed != null && Get.isRegistered<SessionService>()) {
        Get.find<SessionService>().saveSession(refreshed);
      }
      await fetchCurrentCompany();
    } catch (e) {
      log('⚠️ Background refresh & sync error: $e');
    }
  }

  /// Delete company (soft delete).
  Future<bool> deleteCompany(int companyId) async {
    isSubmitting.value = true;
    try {
      final response = await _service.deleteCompany(companyId);
      if (response.statusCode == 200) {
        currentCompany.value = null;
        hasCompany.value = false;
        _storage.write(Constant.companyStatus, false);
        _storage.remove(Constant.companyData);

        if (Get.isRegistered<SessionService>()) {
          Get.find<SessionService>().setCompanyStatus(false);
        }
        return true;
      }
      return false;
    } on DioException catch (e) {
      log('❌ Delete company error: ${e.response?.data}');
      AppSnackbar.error('Failed to delete company');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
