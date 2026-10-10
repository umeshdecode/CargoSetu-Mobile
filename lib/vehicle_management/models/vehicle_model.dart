import 'package:flutter/material.dart';

class VehicleModel {
  final int? id;
  final String chassisNumber;
  final String engineNumber;
  final String registrationNumber;
  final String vehicleType;
  final String model;
  final String manufacturer;
  final double? mileage;
  final int capacityKg;
  final String status;
  final String fuelType;
  final String? registrationDate;
  final String? insuranceExpiryDate;
  final String? pollutionExpiryDate;
  final String? currentLocation;

  // Load Posting Options
  final String? truckType;
  final String? bodyType;
  final double? truckLengthFeet;
  final String? lengthOption;
  final int? wheelerCount;
  final String? wheelerOption;
  final double? passingCapacityTons;
  final String? passingCapacityOption;

  final String? createdAt;
  final String? updatedAt;

  VehicleModel({
    this.id,
    required this.chassisNumber,
    required this.engineNumber,
    required this.registrationNumber,
    required this.vehicleType,
    required this.model,
    required this.manufacturer,
    this.mileage,
    required this.capacityKg,
    this.status = 'AVAILABLE',
    this.fuelType = 'DIESEL',
    this.registrationDate,
    this.insuranceExpiryDate,
    this.pollutionExpiryDate,
    this.currentLocation,
    this.truckType,
    this.bodyType,
    this.truckLengthFeet,
    this.lengthOption,
    this.wheelerCount,
    this.wheelerOption,
    this.passingCapacityTons,
    this.passingCapacityOption,
    this.createdAt,
    this.updatedAt,
  });

  /// Formatted capacity display: e.g. "5 Ton" or "500 Kg"
  String get formattedCapacity {
    if (capacityKg >= 1000 && capacityKg % 1000 == 0) {
      return '${capacityKg ~/ 1000} Ton';
    } else if (capacityKg >= 1000) {
      final tons = (capacityKg / 1000).toStringAsFixed(1);
      return '$tons Ton';
    }
    return '$capacityKg Kg';
  }

  /// Title summary: e.g. "Tata 407 (OPEN_TRUCK)"
  String get displayName {
    final typeLabel = truckType != null && truckType!.isNotEmpty ? truckType! : vehicleType;
    return '$manufacturer $model ($typeLabel)';
  }

  /// Summary of load specs: e.g. "19 Feet | 14 Wheeler | 24-25 Ton"
  String get loadSpecsSummary {
    final parts = <String>[];
    if (lengthOption != null && lengthOption!.isNotEmpty) parts.add(lengthOption!);
    if (wheelerOption != null && wheelerOption!.isNotEmpty) parts.add(wheelerOption!);
    if (passingCapacityOption != null && passingCapacityOption!.isNotEmpty) parts.add(passingCapacityOption!);
    return parts.join(' | ');
  }

  /// Icon matching vehicle body type
  IconData get vehicleIcon {
    final check = (truckType ?? vehicleType).toUpperCase();
    switch (check) {
      case 'TEMPO':
        return Icons.airport_shuttle;
      case 'TRAILER':
        return Icons.rv_hookup;
      case 'CONTAINER':
        return Icons.inventory_2_outlined;
      case 'TANKER':
        return Icons.water_drop_outlined;
      case 'VAN':
      case 'LCV':
        return Icons.directions_car;
      case 'TRUCK':
      case 'OPEN_TRUCK':
      default:
        return Icons.local_shipping;
    }
  }

  /// Status badge color
  Color get statusColor {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return const Color(0xFF16A34A);
      case 'ON_TRIP':
        return const Color(0xFF2563EB);
      case 'MAINTENANCE':
        return const Color(0xFFD97706);
      case 'OUT_OF_SERVICE':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF64748B);
    }
  }

  /// Human readable status label
  String get statusText => status.replaceAll('_', ' ');

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      chassisNumber: (json['chassisNumber'] ?? '').toString(),
      engineNumber: (json['engineNumber'] ?? '').toString(),
      registrationNumber: (json['registrationNumber'] ?? '').toString(),
      vehicleType: (json['vehicleType'] ?? 'TRUCK').toString(),
      model: (json['model'] ?? '').toString(),
      manufacturer: (json['manufacturer'] ?? '').toString(),
      mileage: json['mileage'] != null ? double.tryParse(json['mileage'].toString()) : null,
      capacityKg: json['capacityKg'] is int
          ? json['capacityKg']
          : (json['capacityKg'] != null ? int.tryParse(json['capacityKg'].toString()) ?? 0 : 0),
      status: (json['status'] ?? 'AVAILABLE').toString(),
      fuelType: (json['fuelType'] ?? 'DIESEL').toString(),
      registrationDate: json['registrationDate']?.toString(),
      insuranceExpiryDate: json['insuranceExpiryDate']?.toString(),
      pollutionExpiryDate: json['pollutionExpiryDate']?.toString(),
      currentLocation: json['currentLocation']?.toString(),
      truckType: json['truckType']?.toString(),
      bodyType: json['bodyType']?.toString(),
      truckLengthFeet: json['truckLengthFeet'] != null ? double.tryParse(json['truckLengthFeet'].toString()) : null,
      lengthOption: json['lengthOption']?.toString(),
      wheelerCount: json['wheelerCount'] is int
          ? json['wheelerCount']
          : (json['wheelerCount'] != null ? int.tryParse(json['wheelerCount'].toString()) : null),
      wheelerOption: json['wheelerOption']?.toString(),
      passingCapacityTons: json['passingCapacityTons'] != null ? double.tryParse(json['passingCapacityTons'].toString()) : null,
      passingCapacityOption: json['passingCapacityOption']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'chassisNumber': chassisNumber,
      'engineNumber': engineNumber,
      'registrationNumber': registrationNumber,
      'vehicleType': vehicleType,
      'model': model,
      'manufacturer': manufacturer,
      if (mileage != null) 'mileage': mileage,
      'capacityKg': capacityKg,
      'status': status,
      'fuelType': fuelType,
      if (registrationDate != null) 'registrationDate': registrationDate,
      if (insuranceExpiryDate != null) 'insuranceExpiryDate': insuranceExpiryDate,
      if (pollutionExpiryDate != null) 'pollutionExpiryDate': pollutionExpiryDate,
      if (currentLocation != null) 'currentLocation': currentLocation,
      if (truckType != null) 'truckType': truckType,
      if (bodyType != null) 'bodyType': bodyType,
      if (truckLengthFeet != null) 'truckLengthFeet': truckLengthFeet,
      if (lengthOption != null) 'lengthOption': lengthOption,
      if (wheelerCount != null) 'wheelerCount': wheelerCount,
      if (wheelerOption != null) 'wheelerOption': wheelerOption,
      if (passingCapacityTons != null) 'passingCapacityTons': passingCapacityTons,
      if (passingCapacityOption != null) 'passingCapacityOption': passingCapacityOption,
    };
  }

  VehicleModel copyWith({
    int? id,
    String? chassisNumber,
    String? engineNumber,
    String? registrationNumber,
    String? vehicleType,
    String? model,
    String? manufacturer,
    double? mileage,
    int? capacityKg,
    String? status,
    String? fuelType,
    String? registrationDate,
    String? insuranceExpiryDate,
    String? pollutionExpiryDate,
    String? currentLocation,
    String? truckType,
    String? bodyType,
    double? truckLengthFeet,
    String? lengthOption,
    int? wheelerCount,
    String? wheelerOption,
    double? passingCapacityTons,
    String? passingCapacityOption,
    String? createdAt,
    String? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      engineNumber: engineNumber ?? this.engineNumber,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      model: model ?? this.model,
      manufacturer: manufacturer ?? this.manufacturer,
      mileage: mileage ?? this.mileage,
      capacityKg: capacityKg ?? this.capacityKg,
      status: status ?? this.status,
      fuelType: fuelType ?? this.fuelType,
      registrationDate: registrationDate ?? this.registrationDate,
      insuranceExpiryDate: insuranceExpiryDate ?? this.insuranceExpiryDate,
      pollutionExpiryDate: pollutionExpiryDate ?? this.pollutionExpiryDate,
      currentLocation: currentLocation ?? this.currentLocation,
      truckType: truckType ?? this.truckType,
      bodyType: bodyType ?? this.bodyType,
      truckLengthFeet: truckLengthFeet ?? this.truckLengthFeet,
      lengthOption: lengthOption ?? this.lengthOption,
      wheelerCount: wheelerCount ?? this.wheelerCount,
      wheelerOption: wheelerOption ?? this.wheelerOption,
      passingCapacityTons: passingCapacityTons ?? this.passingCapacityTons,
      passingCapacityOption: passingCapacityOption ?? this.passingCapacityOption,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
