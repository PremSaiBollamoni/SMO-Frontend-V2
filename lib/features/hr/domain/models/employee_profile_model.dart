import 'role_model.dart';

/// Employee profile domain model with detailed information
class EmployeeProfileModel {
  final String empId;
  final String empName;
  final String email;
  final String phone;
  final String address;
  final String dob;
  final String bloodGroup;
  final String emergencyContact;
  final String aadharNumber;
  final String panCardNumber;
  final RoleModel role;
  final String status;

  EmployeeProfileModel({
    required this.empId,
    required this.empName,
    required this.email,
    required this.phone,
    required this.address,
    required this.dob,
    required this.bloodGroup,
    required this.emergencyContact,
    required this.aadharNumber,
    required this.panCardNumber,
    required this.role,
    required this.status,
  });

  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileModel(
      empId: (json['empId'] ?? '').toString(),
      empName: (json['empName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      dob: (json['dob'] ?? '').toString(),
      bloodGroup: (json['bloodGroup'] ?? '').toString(),
      emergencyContact: (json['emergencyContact'] ?? '').toString(),
      aadharNumber: (json['aadharNumber'] ?? '').toString(),
      panCardNumber: (json['panCardNumber'] ?? '').toString(),
      role: RoleModel.fromJson(json['role'] as Map<String, dynamic>),
      status: (json['status'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'empName': empName,
      'email': email,
      'phone': phone,
      'address': address,
      'dob': dob,
      'bloodGroup': bloodGroup,
      'emergencyContact': emergencyContact,
      'aadharNumber': aadharNumber,
      'panCardNumber': panCardNumber,
      'role': role.toJson(),
      'status': status,
    };
  }

  EmployeeProfileModel copyWith({
    String? empId,
    String? empName,
    String? email,
    String? phone,
    String? address,
    String? dob,
    String? bloodGroup,
    String? emergencyContact,
    String? aadharNumber,
    String? panCardNumber,
    RoleModel? role,
    String? status,
  }) {
    return EmployeeProfileModel(
      empId: empId ?? this.empId,
      empName: empName ?? this.empName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dob: dob ?? this.dob,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      panCardNumber: panCardNumber ?? this.panCardNumber,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeProfileModel &&
          runtimeType == other.runtimeType &&
          empId == other.empId &&
          empName == other.empName &&
          email == other.email &&
          phone == other.phone &&
          address == other.address &&
          dob == other.dob &&
          bloodGroup == other.bloodGroup &&
          emergencyContact == other.emergencyContact &&
          aadharNumber == other.aadharNumber &&
          panCardNumber == other.panCardNumber &&
          role == other.role &&
          status == other.status;

  @override
  int get hashCode =>
      empId.hashCode ^
      empName.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      address.hashCode ^
      dob.hashCode ^
      bloodGroup.hashCode ^
      emergencyContact.hashCode ^
      aadharNumber.hashCode ^
      panCardNumber.hashCode ^
      role.hashCode ^
      status.hashCode;
}
