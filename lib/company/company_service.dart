import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/util/url_const.dart';
import 'package:dio/dio.dart';

/// API service for company CRUD operations.
class CompanyService {
  final ApiRequest _api = ApiRequest();

  /// Fetch current user's company
  Future<Response> getCurrentCompany() {
    return _api.get(url: Urls.currentCompany);
  }

  /// Create a new company (multipart for file uploads)
  Future<Response> createCompany(FormData formData) {
    return _api.postMultipart(url: Urls.company, data: formData);
  }

  /// Update existing company (multipart for file uploads)
  Future<Response> updateCompany(FormData formData) {
    return _api.putMultipart(url: Urls.company, data: formData);
  }

  /// Delete company by ID (soft delete)
  Future<Response> deleteCompany(int id) {
    return _api.delete(url: '${Urls.company}/$id');
  }

  /// Get company by UUID
  Future<Response> getCompanyByUuid(String uuid) {
    return _api.get(url: '${Urls.company}/$uuid');
  }

  /// Get all companies (admin only)
  Future<Response> getAllCompanies() {
    return _api.get(url: Urls.company);
  }
}
