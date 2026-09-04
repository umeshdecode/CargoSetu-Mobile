import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/util/url_const.dart';
import 'package:dio/dio.dart';

/// API service for the logged-in user's profile and staff records.
///
/// Every method returns the raw [Response]; unwrapping the `GenericDataDTO`
/// envelope is the controller's job.
class ProfileService {
  final ApiRequest _api = ApiRequest();

  /// `GET /staff/myprofile` — the logged-in user's own profile.
  Future<Response> getMyProfile() {
    return _api.get(url: Urls.myProfile);
  }

  /// `PUT /staff/myprofile` — self-service update (contact/address fields only).
  Future<Response> updateMyProfile(Map<String, dynamic> body) {
    return _api.put(url: Urls.myProfile, data: body);
  }

  /// `POST /staff/myprofile/image` — upload or replace own photo.
  Future<Response> uploadMyProfileImage(FormData formData) {
    return _api.postMultipart(url: Urls.myProfileImage, data: formData);
  }

  /// `DELETE /staff/myprofile/image` — remove own photo.
  Future<Response> deleteMyProfileImage() {
    return _api.delete(url: Urls.myProfileImage);
  }

  /// `GET /staff/{staffId}` — another staff member (needs `STAFF_READ`).
  Future<Response> getStaffById(int staffId) {
    return _api.get(url: Urls.staffById(staffId));
  }

  /// `PUT /staff/{staffId}` — admin update (needs `STAFF_UPDATE_DELETE`).
  Future<Response> updateStaff(int staffId, Map<String, dynamic> body) {
    return _api.put(url: Urls.staffById(staffId), data: body);
  }

  /// `POST /staff/{staffId}/image` — upload another member's photo.
  Future<Response> uploadStaffProfileImage(int staffId, FormData formData) {
    return _api.postMultipart(
      url: Urls.staffProfileImage(staffId),
      data: formData,
    );
  }

  /// `DELETE /staff/{staffId}/image` — remove another member's photo.
  Future<Response> deleteStaffProfileImage(int staffId) {
    return _api.delete(url: Urls.staffProfileImage(staffId));
  }

  /// `GET /staff?page=&size=` — paginated staff list for the company.
  Future<Response> getAllStaff({int page = 0, int size = 20}) {
    return _api.get(
      url: Urls.staff,
      queryParams: {'page': page, 'size': size},
    );
  }

  /// Builds the multipart body the image endpoints expect (part name `file`).
  static Future<FormData> buildImageFormData(String filePath) async {
    final fileName = filePath.split(RegExp(r'[\\/]')).last;
    return FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: _imageMediaType(fileName),
      ),
    });
  }

  /// Dio would otherwise send `application/octet-stream`, which S3 then stores
  /// as the object's content type, so it is derived from the extension.
  static DioMediaType _imageMediaType(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final ext = dot > 0 ? fileName.substring(dot + 1).toLowerCase() : '';
    switch (ext) {
      case 'png':
        return DioMediaType('image', 'png');
      case 'webp':
        return DioMediaType('image', 'webp');
      default:
        return DioMediaType('image', 'jpeg');
    }
  }
}
