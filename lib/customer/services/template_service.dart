import 'dart:developer';
import 'dart:io';
import 'package:cargo_setu/customer/models/template_model.dart';
import 'package:cargo_setu/network/api_request.dart';
import 'package:cargo_setu/util/url_const.dart';
import 'package:dio/dio.dart';

class TemplateService {
  final ApiRequest _api = ApiRequest();

  /// Fetch templates by type (e.g. 'QUOTATION')
  Future<List<TemplateModel>> getTemplatesByType({
    String type = 'QUOTATION',
    int pageNumber = 0,
    int pageSize = 10,
  }) async {
    try {
      final response = await _api.get(
        url: Urls.templatesByType,
        queryParams: {
          'type': type,
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        dynamic rawData = body is Map ? (body['data'] ?? body) : body;

        List items = [];
        if (rawData is Map && rawData['content'] is List) {
          items = rawData['content'] as List;
        } else if (rawData is List) {
          items = rawData;
        }

        return items
            .whereType<Map<String, dynamic>>()
            .map((e) => TemplateModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      log('❌ Fetch templates error: $e');
      rethrow;
    }
  }

  /// Set template as company favourite / default
  Future<bool> setDefaultTemplate(int templateId) async {
    try {
      final response = await _api.put(
        url: Urls.templateDefault(templateId),
      );

      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map && body['responseCode'] != null) {
          return body['responseCode'] == 200;
        }
        return true;
      }
      return false;
    } catch (e) {
      log('❌ Set default template error: $e');
      rethrow;
    }
  }

  /// Fetch template preview HTML content
  Future<String?> getTemplatePreviewHtml(int templateId) async {
    try {
      final response = await _api.get(
        url: Urls.templatePreviewHtml(templateId),
        headers: {
          'Accept': 'text/html, */*',
        },
        receiveTimeout: const Duration(minutes: 2),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data.toString();
      }
      return null;
    } catch (e) {
      log('❌ Get template HTML error: $e');
      rethrow;
    }
  }

  /// Download quotation PDF bytes
  Future<List<int>?> downloadQuotationPdf(int shiftingId, {int? templateId}) async {
    try {
      final response = await _api.get<List<int>>(
        url: Urls.quotationPdf(shiftingId, templateId: templateId),
        responseType: ResponseType.bytes,
        headers: {
          'Accept': 'application/pdf, */*',
        },
        receiveTimeout: const Duration(minutes: 3),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      log('❌ Download quotation PDF error: $e');
      rethrow;
    }
  }

  /// Save PDF bytes to file on device
  Future<String?> savePdfToFile({
    required List<int> bytes,
    required String fileName,
    String? targetDirectoryPath,
  }) async {
    try {
      if (targetDirectoryPath != null && targetDirectoryPath.trim().isNotEmpty) {
        final dir = Directory(targetDirectoryPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final filePath = '${dir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);
        return file.path;
      }

      if (Platform.isAndroid) {
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            final filePath = '${downloadDir.path}/$fileName';
            final file = File(filePath);
            await file.writeAsBytes(bytes, flush: true);
            return file.path;
          }
        } catch (e) {
          log('⚠️ Direct write to Download folder failed, falling back to temp: $e');
        }
      }

      final targetDir = Directory.systemTemp;
      final filePath = '${targetDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e) {
      log('❌ Save PDF to file error: $e');
      return null;
    }
  }

  /// Generate and send quotation to customer's email
  Future<Map<String, dynamic>> sendQuotation(int shiftingId, {int? templateId}) async {
    return sendDocument(docType: 'QUOTATION', shiftingId: shiftingId, templateId: templateId);
  }

  /// Download document PDF bytes (docType: 'QUOTATION', 'PACKING_LIST', etc.)
  Future<List<int>?> downloadDocumentPdf({
    required String docType,
    required int shiftingId,
    int? templateId,
  }) async {
    try {
      final response = await _api.get<List<int>>(
        url: Urls.documentPdf(docType, shiftingId, templateId: templateId),
        responseType: ResponseType.bytes,
        headers: {
          'Accept': 'application/pdf, */*',
        },
        receiveTimeout: const Duration(minutes: 3),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      log('Download $docType PDF error: $e');
      rethrow;
    }
  }

  /// Generate and send document to customer's email (docType: 'QUOTATION', 'PACKING_LIST', etc.)
  Future<Map<String, dynamic>> sendDocument({
    required String docType,
    required int shiftingId,
    int? templateId,
  }) async {
    try {
      final response = await _api.post(
        url: Urls.sendDocument(docType, shiftingId, templateId: templateId),
        receiveTimeout: const Duration(minutes: 3),
      );

      if (response.statusCode == 200) {
        final body = response.data;
        if (body is Map) {
          final isSuccess = body['responseCode'] == 200;
          return {
            'success': isSuccess,
            'message': body['responseMessege'] ??
                (isSuccess ? 'Document sent successfully' : 'Failed to send document'),
          };
        }
        return {'success': true, 'message': 'Document sent successfully'};
      }
      return {'success': false, 'message': 'Failed to send document'};
    } catch (e) {
      log('❌ Send $docType error: $e');
      String msg = '$docType could not be sent. Please try again after some time.';
      if (e is DioException) {
        if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
          msg = '$docType generation is taking longer than usual. Document not generated yet, please try again after some time.';
        } else if (e.response?.data is Map) {
          msg = e.response?.data['responseMessege'] ?? e.response?.data['message'] ?? msg;
        }
      }
      return {'success': false, 'message': msg};
    }
  }
}
