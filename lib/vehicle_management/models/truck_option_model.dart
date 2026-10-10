class TruckOptionModel {
  final int? id;
  final String truckType;
  final String displayName;
  final bool active;
  final List<String> bodyTypes;
  final List<String> availableLengthsFeet;
  final List<String> availableWheelers;
  final List<String> availablePassingTons;

  TruckOptionModel({
    this.id,
    required this.truckType,
    required this.displayName,
    this.active = true,
    this.bodyTypes = const [],
    this.availableLengthsFeet = const [],
    this.availableWheelers = const [],
    this.availablePassingTons = const [],
  });

  factory TruckOptionModel.fromJson(Map<String, dynamic> json) {
    return TruckOptionModel(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      truckType: (json['truckType'] ?? '').toString(),
      displayName: (json['displayName'] ?? json['truckType'] ?? '').toString(),
      active: json['active'] == true || json['active'] == null,
      bodyTypes: json['bodyTypes'] is List
          ? (json['bodyTypes'] as List).map((e) => e.toString()).toList()
          : [],
      availableLengthsFeet: json['availableLengthsFeet'] is List
          ? (json['availableLengthsFeet'] as List).map((e) => e.toString()).toList()
          : [],
      availableWheelers: json['availableWheelers'] is List
          ? (json['availableWheelers'] as List).map((e) => e.toString()).toList()
          : [],
      availablePassingTons: json['availablePassingTons'] is List
          ? (json['availablePassingTons'] as List).map((e) => e.toString()).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'truckType': truckType,
      'displayName': displayName,
      'active': active,
      'bodyTypes': bodyTypes,
      'availableLengthsFeet': availableLengthsFeet,
      'availableWheelers': availableWheelers,
      'availablePassingTons': availablePassingTons,
    };
  }
}
