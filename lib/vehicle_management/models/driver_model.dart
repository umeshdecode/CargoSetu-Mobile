class DriverModel {
  final int? id;
  final String name;
  final String phoneNumber;
  final String email;
  final String licenseNumber;
  final String? licenseExpiryDate;
  final int? experienceYears;
  final String? address;
  final String status;
  final String? joiningDate;
  final String? createdAt;
  final String? updatedAt;

  DriverModel({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.licenseNumber,
    this.licenseExpiryDate,
    this.experienceYears,
    this.address,
    this.status = 'ACTIVE',
    this.joiningDate,
    this.createdAt,
    this.updatedAt,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'D';
  }

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      name: (json['name'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      licenseNumber: (json['licenseNumber'] ?? '').toString(),
      licenseExpiryDate: json['licenseExpiryDate']?.toString(),
      experienceYears: json['experienceYears'] != null
          ? int.tryParse(json['experienceYears'].toString())
          : null,
      address: json['address']?.toString(),
      status: (json['status'] ?? 'ACTIVE').toString(),
      joiningDate: json['joiningDate']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'licenseNumber': licenseNumber,
      if (licenseExpiryDate != null) 'licenseExpiryDate': licenseExpiryDate,
      if (experienceYears != null) 'experienceYears': experienceYears,
      if (address != null) 'address': address,
      'status': status,
      if (joiningDate != null) 'joiningDate': joiningDate,
    };
  }

  DriverModel copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? licenseNumber,
    String? licenseExpiryDate,
    int? experienceYears,
    String? address,
    String? status,
    String? joiningDate,
    String? createdAt,
    String? updatedAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      experienceYears: experienceYears ?? this.experienceYears,
      address: address ?? this.address,
      status: status ?? this.status,
      joiningDate: joiningDate ?? this.joiningDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
