class PackingItemModel {
  final int? id;
  final int shiftId;
  final String roomName;
  final String itemName;
  final String category;
  final String packageNumber;
  final String remarks;
  final String conditionStatus;
  final bool packed;
  final bool loaded;
  final bool unloaded;

  PackingItemModel({
    this.id,
    required this.shiftId,
    this.roomName = 'General',
    required this.itemName,
    this.category = 'Miscellaneous',
    this.packageNumber = '',
    this.remarks = '',
    this.conditionStatus = 'Good',
    this.packed = false,
    this.loaded = false,
    this.unloaded = false,
  });

  factory PackingItemModel.fromJson(Map<String, dynamic> json) {
    return PackingItemModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      shiftId: json['shiftId'] is int ? json['shiftId'] as int : (int.tryParse(json['shiftId']?.toString() ?? '0') ?? 0),
      roomName: json['roomName'] ?? 'General',
      itemName: json['itemName'] ?? '',
      category: json['category'] ?? 'Miscellaneous',
      packageNumber: json['packageNumber'] ?? '',
      remarks: json['remarks'] ?? '',
      conditionStatus: json['conditionStatus'] ?? 'Good',
      packed: json['packed'] ?? false,
      loaded: json['loaded'] ?? false,
      unloaded: json['unloaded'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'shiftId': shiftId,
      'roomName': roomName,
      'itemName': itemName,
      'category': category,
      'packageNumber': packageNumber,
      'remarks': remarks,
      'conditionStatus': conditionStatus,
      'packed': packed,
      'loaded': loaded,
      'unloaded': unloaded,
    };
  }

  PackingItemModel copyWith({
    int? id,
    int? shiftId,
    String? roomName,
    String? itemName,
    String? category,
    String? packageNumber,
    String? remarks,
    String? conditionStatus,
    bool? packed,
    bool? loaded,
    bool? unloaded,
  }) {
    return PackingItemModel(
      id: id ?? this.id,
      shiftId: shiftId ?? this.shiftId,
      roomName: roomName ?? this.roomName,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      packageNumber: packageNumber ?? this.packageNumber,
      remarks: remarks ?? this.remarks,
      conditionStatus: conditionStatus ?? this.conditionStatus,
      packed: packed ?? this.packed,
      loaded: loaded ?? this.loaded,
      unloaded: unloaded ?? this.unloaded,
    );
  }
}
