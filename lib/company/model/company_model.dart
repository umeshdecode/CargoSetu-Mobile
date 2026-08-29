import 'dart:io';
import 'package:dio/dio.dart';

/// Company model matching backend Company entity (tblmcompany).
class CompanyModel {
  final int? companyId;
  final String? companyUUID;
  final String companyName;
  final String companyEmail;
  final String? whatsappNumber;
  final String? contactNo1;
  final String? contactNo2;
  final String? landlineNo;
  final String? tollFreeNumber;
  final String? panNumber;
  final String? gstNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? branch;
  final String? mainBranch;
  final String? website;
  final String? logoBase64;
  final String? sealBase64;
  final bool isActive;
  final List<CompanyAsset>? assets;

  CompanyModel({
    this.companyId,
    this.companyUUID,
    required this.companyName,
    required this.companyEmail,
    this.whatsappNumber,
    this.contactNo1,
    this.contactNo2,
    this.landlineNo,
    this.tollFreeNumber,
    this.panNumber,
    this.gstNumber,
    this.address,
    this.city,
    this.state,
    this.country,
    this.branch,
    this.mainBranch,
    this.website,
    this.logoBase64,
    this.sealBase64,
    this.isActive = true,
    this.assets,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      companyId: json['companyId'] as int?,
      companyUUID: json['companyUUID'] as String?,
      companyName: json['companyName'] as String? ?? '',
      companyEmail: json['companyEmail'] as String? ?? '',
      whatsappNumber: _parsePhone(json['whatsappNumber']),
      contactNo1: _parsePhone(json['contactNo1']),
      contactNo2: _parsePhone(json['contactNo2']),
      landlineNo: json['landlineNo'] as String?,
      tollFreeNumber: json['tollFreeNumber'] as String?,
      panNumber: json['panNumber'] as String?,
      gstNumber: json['gstNumber'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      branch: json['branch'] as String?,
      mainBranch: json['mainBranch'] as String?,
      website: json['website'] as String?,
      logoBase64: json['logoBase64'] as String?,
      sealBase64: json['sealBase64'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      assets: json['assets'] != null
          ? (json['assets'] as List)
              .map((a) => CompanyAsset.fromJson(a as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (companyId != null) 'companyId': companyId,
      if (companyUUID != null) 'companyUUID': companyUUID,
      'companyName': companyName,
      'companyEmail': companyEmail,
      if (whatsappNumber != null) 'whatsappNumber': whatsappNumber,
      if (contactNo1 != null) 'contactNo1': contactNo1,
      if (contactNo2 != null) 'contactNo2': contactNo2,
      if (landlineNo != null) 'landlineNo': landlineNo,
      if (tollFreeNumber != null) 'tollFreeNumber': tollFreeNumber,
      if (panNumber != null) 'panNumber': panNumber,
      if (gstNumber != null) 'gstNumber': gstNumber,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (branch != null) 'branch': branch,
      if (mainBranch != null) 'mainBranch': mainBranch,
      if (website != null) 'website': website,
      'isActive': isActive,
    };
  }

  /// Get the best available logo URL or Base64 data string
  String? get logoUrlOrBase64 {
    if (assets != null && assets!.isNotEmpty) {
      final logo = assets!.firstWhere(
        (a) => a.assetType == 'LOGO',
        orElse: () => CompanyAsset(assetType: 'LOGO'),
      );
      if (logo.fileUrl != null && logo.fileUrl!.isNotEmpty) {
        return logo.fileUrl;
      }
    }
    if (logoBase64 != null && logoBase64!.isNotEmpty) {
      return logoBase64;
    }
    return null;
  }

  /// Convert to FormData for multipart upload with backend parameter alignment.
  Future<FormData> toFormData({List<AssetUpload>? assetUploads}) async {
    final formData = FormData();

    // Required and standard fields
    formData.fields.add(MapEntry('companyName', companyName.trim()));
    formData.fields.add(MapEntry('companyEmail', companyEmail.trim()));

    if (companyId != null) {
      formData.fields.add(MapEntry('companyId', companyId.toString()));
    }

    // Number fields MUST be clean digits for backend Long deserialization
    final cleanWhatsapp = _cleanDigits(whatsappNumber);
    if (cleanWhatsapp.isNotEmpty) {
      formData.fields.add(MapEntry('whatsappNumber', cleanWhatsapp));
    }

    final cleanContact1 = _cleanDigits(contactNo1);
    if (cleanContact1.isNotEmpty) {
      formData.fields.add(MapEntry('contactNo1', cleanContact1));
    }

    final cleanContact2 = _cleanDigits(contactNo2);
    if (cleanContact2.isNotEmpty) {
      formData.fields.add(MapEntry('contactNo2', cleanContact2));
    }

    if (landlineNo != null && landlineNo!.trim().isNotEmpty) {
      formData.fields.add(MapEntry('landlineNo', landlineNo!.trim()));
    }
    if (tollFreeNumber != null && tollFreeNumber!.trim().isNotEmpty) {
      formData.fields.add(MapEntry('tollFreeNumber', tollFreeNumber!.trim()));
    }

    // PAN and GST must be uppercase
    if (panNumber != null && panNumber!.trim().isNotEmpty) {
      formData.fields.add(MapEntry('panNumber', panNumber!.trim().toUpperCase()));
    }
    if (gstNumber != null && gstNumber!.trim().isNotEmpty) {
      formData.fields.add(MapEntry('gstNumber', gstNumber!.trim().toUpperCase()));
    }

    // Address fields
    if (address != null && address!.trim().isNotEmpty) {
      formData.fields.add(MapEntry('address', address!.trim()));
    }
    if (city != null && city!.trim().isNotEmpty) {
      formData.fields.add(MapEntry('city', city!.trim()));
    }
    if (state != null && state!.trim().isNotEmpty) {
      formData.fields.add(MapEntry('state', state!.trim()));
    }
    if (country != null && country!.trim().isNotEmpty) {
      formData.fields.add(MapEntry('country', country!.trim()));
    } else {
      formData.fields.add(const MapEntry('country', 'India'));
    }

    if (branch != null && branch!.trim().isNotEmpty) {
      formData.fields.add(MapEntry('branch', branch!.trim()));
    }
    if (mainBranch != null && mainBranch!.trim().isNotEmpty) {
      formData.fields.add(MapEntry('mainBranch', mainBranch!.trim()));
    }
    if (website != null && website!.trim().isNotEmpty) {
      formData.fields.add(MapEntry('website', website!.trim()));
    }

    formData.fields.add(MapEntry('isActive', isActive.toString()));

    // Multipart asset files (e.g. LOGO, SEAL, STAMP)
    if (assetUploads != null && assetUploads.isNotEmpty) {
      for (var i = 0; i < assetUploads.length; i++) {
        final asset = assetUploads[i];
        formData.fields.add(MapEntry('assets[$i].assetType', asset.assetType));

        final fileName = asset.file.path.split(Platform.pathSeparator).last;
        formData.files.add(
          MapEntry(
            'assets[$i].file',
            await MultipartFile.fromFile(
              asset.file.path,
              filename: fileName,
            ),
          ),
        );
      }
    }

    return formData;
  }

  static String? _parsePhone(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static String _cleanDigits(String? value) {
    if (value == null) return '';
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  CompanyModel copyWith({
    int? companyId,
    String? companyUUID,
    String? companyName,
    String? companyEmail,
    String? whatsappNumber,
    String? contactNo1,
    String? contactNo2,
    String? landlineNo,
    String? tollFreeNumber,
    String? panNumber,
    String? gstNumber,
    String? address,
    String? city,
    String? state,
    String? country,
    String? branch,
    String? mainBranch,
    String? website,
    String? logoBase64,
    String? sealBase64,
    bool? isActive,
    List<CompanyAsset>? assets,
  }) {
    return CompanyModel(
      companyId: companyId ?? this.companyId,
      companyUUID: companyUUID ?? this.companyUUID,
      companyName: companyName ?? this.companyName,
      companyEmail: companyEmail ?? this.companyEmail,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      contactNo1: contactNo1 ?? this.contactNo1,
      contactNo2: contactNo2 ?? this.contactNo2,
      landlineNo: landlineNo ?? this.landlineNo,
      tollFreeNumber: tollFreeNumber ?? this.tollFreeNumber,
      panNumber: panNumber ?? this.panNumber,
      gstNumber: gstNumber ?? this.gstNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      branch: branch ?? this.branch,
      mainBranch: mainBranch ?? this.mainBranch,
      website: website ?? this.website,
      logoBase64: logoBase64 ?? this.logoBase64,
      sealBase64: sealBase64 ?? this.sealBase64,
      isActive: isActive ?? this.isActive,
      assets: assets ?? this.assets,
    );
  }
}

/// Company asset (logo, seal, signature, stamp).
class CompanyAsset {
  final int? id;
  final int? companyId;
  final String assetType;
  final String? filePath;
  final String? fileUrl;

  CompanyAsset({
    this.id,
    this.companyId,
    required this.assetType,
    this.filePath,
    this.fileUrl,
  });

  factory CompanyAsset.fromJson(Map<String, dynamic> json) {
    return CompanyAsset(
      id: json['id'] as int?,
      companyId: json['companyId'] as int?,
      assetType: json['assetType'] as String? ?? 'LOGO',
      filePath: json['filePath'] as String?,
      fileUrl: json['fileUrl'] as String?,
    );
  }
}

/// Asset upload helper for multipart requests.
class AssetUpload {
  final String assetType; // LOGO, SEAL, SIGNATURE, STAMP
  final File file;

  AssetUpload({required this.assetType, required this.file});
}
