class SignUpRequest {
  final String userName; // 👈 ADD THIS
  final String firstName;
  final String lastName;
  final String email;
  final String dob;
  final String mobileNumber;
  final String mobileCode;
  final String staffType;
  final int departmentId;
  final bool isActive;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final String address;
  final String password;

  SignUpRequest({
    required this.userName, // 👈 ADD
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dob,
    required this.mobileNumber,
    required this.mobileCode,
    required this.staffType,
    required this.departmentId,
    required this.isActive,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    required this.address,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "userName": userName, // 👈 ADD
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "dob": dob,
      "mobileNumber": mobileNumber,
      "mobileCode": mobileCode,
      "staffType": staffType,
      "departmentId": departmentId,
      "isActive": isActive,
      "city": city,
      "state": state,
      "pincode": pincode,
      "country": country,
      "address": address,
      "password": password,
    };
  }
}
