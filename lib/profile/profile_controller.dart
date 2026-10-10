import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cargo_setu/profile/model/staff_model.dart';
import 'package:cargo_setu/profile/profile_service.dart';
import 'package:cargo_setu/services/session_service.dart';
import 'package:cargo_setu/util/constant.dart';
import 'package:cargo_setu/widgets/app_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';

/// Controller for the logged-in user's profile plus staff read/update.
///
/// Backed by `GET/PUT /staff/myprofile` and the `/image` sub-routes. The last
/// fetched profile is cached in GetStorage under [Constant.staffInfo] so the
/// profile tab paints instantly on the next launch.
class ProfileController extends GetxController {
  final ProfileService _service = ProfileService();
  final GetStorage _storage = GetStorage();

  /// Logged-in user's profile.
  final Rx<StaffModel?> profile = Rx<StaffModel?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isUploadingImage = false.obs;

  /// Last failure, surfaced by the profile screen when there is nothing cached.
  final RxString errorMessage = ''.obs;

  StaffModel? get staff => profile.value;
  bool get hasProfile => profile.value != null;

  @override
  void onInit() {
    super.onInit();
    _loadCachedProfile();
    fetchMyProfile(showLoader: profile.value == null);
  }

  /// Hydrate from the cached payload so the UI is never empty while fetching.
  void _loadCachedProfile() {
    final cached = _storage.read(Constant.staffInfo);
    if (cached == null) return;
    try {
      final Map<String, dynamic> json = cached is String
          ? jsonDecode(cached) as Map<String, dynamic>
          : Map<String, dynamic>.from(cached as Map);
      profile.value = StaffModel.fromJson(json);
      _syncSession(profile.value);
      log('📦 Loaded cached profile: ${profile.value?.displayName}');
    } catch (e) {
      log('⚠️ Error parsing cached profile: $e');
    }
  }

  /// `GET /staff/myprofile`. Returns true when a profile was loaded.
  Future<bool> fetchMyProfile({bool showLoader = true}) async {
    if (showLoader) isLoading.value = true;
    try {
      final response = await _service.getMyProfile();
      final map = _unwrap(response);
      if (map != null) {
        _applyProfile(map);
        errorMessage.value = '';
        return true;
      }
      errorMessage.value =
          _envelopeMessage(response.data) ?? 'Could not load your profile';
      return false;
    } catch (e) {
      errorMessage.value = _friendlyError(e, 'Could not load your profile');
      log('❌ Fetch profile error: ${errorMessage.value}');
      return false;
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  /// `PUT /staff/myprofile` with the self-service field whitelist.
  Future<bool> updateMyProfile(StaffModel updated) async {
    isSubmitting.value = true;
    try {
      final response = await _service.updateMyProfile(updated.toMyProfileJson());
      final map = _unwrap(response);
      if (map != null) {
        _applyProfile(map);
        errorMessage.value = '';
        return true;
      }
      _notifyError(_envelopeMessage(response.data) ?? 'Failed to update profile');
      return false;
    } catch (e) {
      _notifyError(_friendlyError(e, 'Failed to update profile'));
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// `POST /staff/myprofile/image` — upload or replace the photo.
  Future<bool> uploadProfileImage(File file) async {
    isUploadingImage.value = true;
    try {
      final formData = await ProfileService.buildImageFormData(file.path);
      final response = await _service.uploadMyProfileImage(formData);
      final map = _unwrap(response);
      if (map != null) {
        _applyProfile(map);
        return true;
      }
      _notifyError(
          _envelopeMessage(response.data) ?? 'Failed to upload profile photo');
      return false;
    } catch (e) {
      _notifyError(_friendlyError(e, 'Failed to upload profile photo'));
      return false;
    } finally {
      isUploadingImage.value = false;
    }
  }

  /// `DELETE /staff/myprofile/image` — remove the photo.
  Future<bool> removeProfileImage() async {
    isUploadingImage.value = true;
    try {
      final response = await _service.deleteMyProfileImage();
      final map = _unwrap(response);
      if (map != null) {
        _applyProfile(map);
        return true;
      }
      // The server may answer without a body; clear locally and re-sync.
      if (response.statusCode == 200) {
        profile.value = profile.value?.copyWith(clearProfileImage: true);
        _cacheProfile(profile.value);
        _syncSession(profile.value, clearImage: true);
        return true;
      }
      _notifyError(
          _envelopeMessage(response.data) ?? 'Failed to remove profile photo');
      return false;
    } catch (e) {
      _notifyError(_friendlyError(e, 'Failed to remove profile photo'));
      return false;
    } finally {
      isUploadingImage.value = false;
    }
  }

  // ─── STAFF (ADMIN) ────────────────────────────────────────

  /// `GET /staff/{staffId}` — needs `STAFF_READ` or Company Admin.
  Future<StaffModel?> fetchStaffById(int staffId) async {
    isLoading.value = true;
    try {
      final map = _unwrap(await _service.getStaffById(staffId));
      return map == null ? null : StaffModel.fromJson(map);
    } catch (e) {
      _notifyError(_friendlyError(e, 'Could not load staff details'));
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// `PUT /staff/{staffId}` — needs `STAFF_UPDATE_DELETE`.
  ///
  /// When the edited record is the logged-in user's own, local state is
  /// refreshed from the response too.
  Future<StaffModel?> updateStaff(int staffId, StaffModel staffToSave) async {
    isSubmitting.value = true;
    try {
      final response = await _service.updateStaff(staffId, staffToSave.toJson());
      final map = _unwrap(response);
      if (map != null) {
        final saved = StaffModel.fromJson(map);
        if (saved.staffId != null && saved.staffId == profile.value?.staffId) {
          _applyProfile(map);
        }
        return saved;
      }
      _notifyError(_envelopeMessage(response.data) ?? 'Failed to update staff');
      return null;
    } catch (e) {
      _notifyError(_friendlyError(e, 'Failed to update staff'));
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// `GET /staff?page=&size=` — company staff list.
  Future<List<StaffModel>> fetchAllStaff({int page = 0, int size = 20}) async {
    try {
      final response = await _service.getAllStaff(page: page, size: size);
      final data = response.data;
      final list = data is Map ? (data['data'] ?? data['dataList']) : null;
      if (list is List) {
        return list
            .whereType<Map>()
            .map((e) => StaffModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return const [];
    } catch (e) {
      log('❌ Fetch staff list error: ${_friendlyError(e, 'failed')}');
      return const [];
    }
  }

  // ─── INTERNALS ────────────────────────────────────────────

  void _applyProfile(Map<String, dynamic> map) {
    final model = StaffModel.fromJson(map);
    profile.value = model;
    _cacheProfile(model, raw: map);
    _syncSession(model, clearImage: !model.hasProfileImage);
  }

  void _cacheProfile(StaffModel? model, {Map<String, dynamic>? raw}) {
    if (model == null) {
      _storage.remove(Constant.staffInfo);
      return;
    }
    try {
      _storage.write(Constant.staffInfo, jsonEncode(raw ?? _toCacheJson(model)));
    } catch (e) {
      log('⚠️ Could not cache profile: $e');
    }
  }

  /// Cache shape mirrors the API payload so [StaffModel.fromJson] can read it
  /// back, including the fields the write payloads leave out.
  Map<String, dynamic> _toCacheJson(StaffModel model) {
    final json = model.toJson();
    json['profileImageUrl'] = model.profileImageUrl;
    json['userName'] = model.userName;
    json['roles'] = model.roles.map((r) => r.toJson()).toList();
    return json;
  }

  /// Push the display name, email and photo into the shared session so the
  /// drawer and dashboard header stay in step.
  void _syncSession(StaffModel? model, {bool clearImage = false}) {
    if (model == null || !Get.isRegistered<SessionService>()) return;
    Get.find<SessionService>().updateIdentity(
      userName: model.fullName.isNotEmpty ? model.fullName : model.userName,
      email: model.email,
      profileImageUrl: clearImage ? '' : model.profileImageUrl,
    );
  }

  /// Pulls the staff object out of the `GenericDataDTO` envelope, or null when
  /// the call did not succeed.
  Map<String, dynamic>? _unwrap(Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) return null;
    final data = response.data;
    if (data is! Map) return null;
    final code = data['responseCode'];
    if (code != null && code != 200 && code != 201) return null;
    final payload = data['data'];
    if (payload is Map) return Map<String, dynamic>.from(payload);
    return null;
  }

  String? _envelopeMessage(dynamic data) {
    if (data is Map) {
      final msg = data['responseMessege'] ?? data['message'] ?? data['error'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString();
      }
    }
    return null;
  }

  String _friendlyError(Object error, String fallback) {
    if (error is DioException) {
      final fromBody = _envelopeMessage(error.response?.data);
      if (fromBody != null) return fromBody;
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Server unreachable. Check your connection and try again.';
      }
      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403) {
        return 'Your session has expired. Please log in again.';
      }
    }
    return fallback;
  }

  void _notifyError(String message) {
    errorMessage.value = message;
    log('❌ Profile: $message');
    AppSnackbar.error(message);
  }
}
