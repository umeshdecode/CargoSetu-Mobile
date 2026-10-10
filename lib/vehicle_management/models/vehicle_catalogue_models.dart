class CatalogueBrandModel {
  final int id;
  final String name;
  final String slug;

  CatalogueBrandModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory CatalogueBrandModel.fromJson(Map<String, dynamic> json) {
    return CatalogueBrandModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
    );
  }
}

class CatalogueModelItem {
  final int id;
  final String name;
  final String slug;
  final String? brandName;
  final String? brandSlug;

  CatalogueModelItem({
    required this.id,
    required this.name,
    required this.slug,
    this.brandName,
    this.brandSlug,
  });

  factory CatalogueModelItem.fromJson(Map<String, dynamic> json) {
    String? bName;
    String? bSlug;
    if (json['brand'] is Map) {
      bName = json['brand']['name']?.toString();
      bSlug = json['brand']['slug']?.toString();
    }

    return CatalogueModelItem(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      brandName: bName,
      brandSlug: bSlug,
    );
  }
}

class CatalogueDetailModel {
  final int id;
  final CatalogueBrandModel? brand;
  final String name;
  final String slug;
  final String? category;
  final String? subCategory;
  final String? seriesName;
  final String? brochureUrl;
  final List<String> images;
  final CatalogueSpecModel? specifications;

  CatalogueDetailModel({
    required this.id,
    this.brand,
    required this.name,
    required this.slug,
    this.category,
    this.subCategory,
    this.seriesName,
    this.brochureUrl,
    this.images = const [],
    this.specifications,
  });

  factory CatalogueDetailModel.fromJson(Map<String, dynamic> json) {
    return CatalogueDetailModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      brand: json['brand'] is Map ? CatalogueBrandModel.fromJson(json['brand']) : null,
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      category: json['category']?.toString(),
      subCategory: json['subCategory']?.toString(),
      seriesName: json['seriesName']?.toString(),
      brochureUrl: json['brochureUrl']?.toString(),
      images: json['images'] is List ? (json['images'] as List).map((e) => e.toString()).toList() : [],
      specifications: json['specifications'] is Map
          ? CatalogueSpecModel.fromJson(json['specifications'])
          : null,
    );
  }
}

class CatalogueSpecModel {
  final String? engineType;
  final int? engineCylinders;
  final int? engineDisplacementCc;
  final String? fuelType;
  final String? emissionNorm;
  final double? mileageKmpl;
  final int? fuelTankCapacityLitres;
  final double? torqueNm;
  final double? enginePowerHp;
  final int? engineRpm;
  final double? maxSpeedKmh;
  final double? gradeability;

  // Dimensions
  final int? turningRadiusMm;
  final int? wheelbaseMm;
  final int? deckLengthMm;
  final int? groundClearanceMm;
  final int? overallWidthMm;
  final int? overallHeightMm;
  final int? overallLengthMm;

  // Weight / loading
  final int? kerbWeightKg;
  final int? gvwKg;
  final int? payloadKg;
  final String? gearbox;

  // Axle / brake / suspension
  final String? axleConfig;
  final String? frontAxle;
  final String? rearAxle;
  final String? frontSuspension;
  final String? rearSuspension;
  final String? brakeType;
  final bool? abs;

  // Body / cabin
  final String? chassisType;
  final String? cabinType;
  final String? bodyOption;
  final int? seatingCapacity;

  // Tyres
  final bool? tubelessTyres;
  final String? frontTyre;
  final String? rearTyre;
  final int? numberOfTyres;

  CatalogueSpecModel({
    this.engineType,
    this.engineCylinders,
    this.engineDisplacementCc,
    this.fuelType,
    this.emissionNorm,
    this.mileageKmpl,
    this.fuelTankCapacityLitres,
    this.torqueNm,
    this.enginePowerHp,
    this.engineRpm,
    this.maxSpeedKmh,
    this.gradeability,
    this.turningRadiusMm,
    this.wheelbaseMm,
    this.deckLengthMm,
    this.groundClearanceMm,
    this.overallWidthMm,
    this.overallHeightMm,
    this.overallLengthMm,
    this.kerbWeightKg,
    this.gvwKg,
    this.payloadKg,
    this.gearbox,
    this.axleConfig,
    this.frontAxle,
    this.rearAxle,
    this.frontSuspension,
    this.rearSuspension,
    this.brakeType,
    this.abs,
    this.chassisType,
    this.cabinType,
    this.bodyOption,
    this.seatingCapacity,
    this.tubelessTyres,
    this.frontTyre,
    this.rearTyre,
    this.numberOfTyres,
  });

  factory CatalogueSpecModel.fromJson(Map<String, dynamic> json) {
    return CatalogueSpecModel(
      engineType: json['engineType']?.toString(),
      engineCylinders: json['engineCylinders'] is int
          ? json['engineCylinders']
          : (json['engineCylinders'] != null ? int.tryParse(json['engineCylinders'].toString()) : null),
      engineDisplacementCc: json['engineDisplacementCc'] is int
          ? json['engineDisplacementCc']
          : (json['engineDisplacementCc'] != null ? int.tryParse(json['engineDisplacementCc'].toString()) : null),
      fuelType: json['fuelType']?.toString(),
      emissionNorm: json['emissionNorm']?.toString(),
      mileageKmpl: json['mileageKmpl'] != null ? double.tryParse(json['mileageKmpl'].toString()) : null,
      fuelTankCapacityLitres: json['fuelTankCapacityLitres'] is int
          ? json['fuelTankCapacityLitres']
          : (json['fuelTankCapacityLitres'] != null ? int.tryParse(json['fuelTankCapacityLitres'].toString()) : null),
      torqueNm: json['torqueNm'] != null ? double.tryParse(json['torqueNm'].toString()) : null,
      enginePowerHp: json['enginePowerHp'] != null ? double.tryParse(json['enginePowerHp'].toString()) : null,
      engineRpm: json['engineRpm'] is int
          ? json['engineRpm']
          : (json['engineRpm'] != null ? int.tryParse(json['engineRpm'].toString()) : null),
      maxSpeedKmh: json['maxSpeedKmh'] != null ? double.tryParse(json['maxSpeedKmh'].toString()) : null,
      gradeability: json['gradeability'] != null ? double.tryParse(json['gradeability'].toString()) : null,
      turningRadiusMm: json['turningRadiusMm'] is int
          ? json['turningRadiusMm']
          : (json['turningRadiusMm'] != null ? int.tryParse(json['turningRadiusMm'].toString()) : null),
      wheelbaseMm: json['wheelbaseMm'] is int
          ? json['wheelbaseMm']
          : (json['wheelbaseMm'] != null ? int.tryParse(json['wheelbaseMm'].toString()) : null),
      deckLengthMm: json['deckLengthMm'] is int
          ? json['deckLengthMm']
          : (json['deckLengthMm'] != null ? int.tryParse(json['deckLengthMm'].toString()) : null),
      groundClearanceMm: json['groundClearanceMm'] is int
          ? json['groundClearanceMm']
          : (json['groundClearanceMm'] != null ? int.tryParse(json['groundClearanceMm'].toString()) : null),
      overallWidthMm: json['overallWidthMm'] is int
          ? json['overallWidthMm']
          : (json['overallWidthMm'] != null ? int.tryParse(json['overallWidthMm'].toString()) : null),
      overallHeightMm: json['overallHeightMm'] is int
          ? json['overallHeightMm']
          : (json['overallHeightMm'] != null ? int.tryParse(json['overallHeightMm'].toString()) : null),
      overallLengthMm: json['overallLengthMm'] is int
          ? json['overallLengthMm']
          : (json['overallLengthMm'] != null ? int.tryParse(json['overallLengthMm'].toString()) : null),
      kerbWeightKg: json['kerbWeightKg'] is int
          ? json['kerbWeightKg']
          : (json['kerbWeightKg'] != null ? int.tryParse(json['kerbWeightKg'].toString()) : null),
      gvwKg: json['gvwKg'] is int
          ? json['gvwKg']
          : (json['gvwKg'] != null ? int.tryParse(json['gvwKg'].toString()) : null),
      payloadKg: json['payloadKg'] is int
          ? json['payloadKg']
          : (json['payloadKg'] != null ? int.tryParse(json['payloadKg'].toString()) : null),
      gearbox: json['gearbox']?.toString(),
      axleConfig: json['axleConfig']?.toString(),
      frontAxle: json['frontAxle']?.toString(),
      rearAxle: json['rearAxle']?.toString(),
      frontSuspension: json['frontSuspension']?.toString(),
      rearSuspension: json['rearSuspension']?.toString(),
      brakeType: json['brakeType']?.toString(),
      abs: json['abs'] == true,
      chassisType: json['chassisType']?.toString(),
      cabinType: json['cabinType']?.toString(),
      bodyOption: json['bodyOption']?.toString(),
      seatingCapacity: json['seatingCapacity'] is int
          ? json['seatingCapacity']
          : (json['seatingCapacity'] != null ? int.tryParse(json['seatingCapacity'].toString()) : null),
      tubelessTyres: json['tubelessTyres'] == true,
      frontTyre: json['frontTyre']?.toString(),
      rearTyre: json['rearTyre']?.toString(),
      numberOfTyres: json['numberOfTyres'] is int
          ? json['numberOfTyres']
          : (json['numberOfTyres'] != null ? int.tryParse(json['numberOfTyres'].toString()) : null),
    );
  }
}
