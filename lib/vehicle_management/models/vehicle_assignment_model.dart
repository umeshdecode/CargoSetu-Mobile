class VehicleAssignmentModel {
  final int? id;
  final int driverId;
  final String driverName;
  final int vehicleId;
  final String registrationNumber;
  final String? assignedAt;
  final String? unassignedAt;
  final bool active;
  final String? remarks;
  final String? createdAt;
  final String? updatedAt;

  VehicleAssignmentModel({
    this.id,
    required this.driverId,
    required this.driverName,
    required this.vehicleId,
    required this.registrationNumber,
    this.assignedAt,
    this.unassignedAt,
    this.active = true,
    this.remarks,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleAssignmentModel.fromJson(Map<String, dynamic> json) {
    return VehicleAssignmentModel(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      driverId: json['driverId'] is int
          ? json['driverId']
          : (json['driverId'] != null ? int.tryParse(json['driverId'].toString()) ?? 0 : 0),
      driverName: (json['driverName'] ?? 'Unknown Driver').toString(),
      vehicleId: json['vehicleId'] is int
          ? json['vehicleId']
          : (json['vehicleId'] != null ? int.tryParse(json['vehicleId'].toString()) ?? 0 : 0),
      registrationNumber: (json['registrationNumber'] ?? '').toString(),
      assignedAt: json['assignedAt']?.toString(),
      unassignedAt: json['unassignedAt']?.toString(),
      active: json['active'] == true || json['active'] == 'true',
      remarks: json['remarks']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'driverId': driverId,
      'driverName': driverName,
      'vehicleId': vehicleId,
      'registrationNumber': registrationNumber,
      if (assignedAt != null) 'assignedAt': assignedAt,
      if (unassignedAt != null) 'unassignedAt': unassignedAt,
      'active': active,
      if (remarks != null) 'remarks': remarks,
    };
  }
}
