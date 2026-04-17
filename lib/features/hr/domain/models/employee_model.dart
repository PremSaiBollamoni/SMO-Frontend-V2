import 'role_model.dart';

/// Employee domain model
class EmployeeModel {
  final String empId;
  final String empName;
  final RoleModel role;
  final String email;
  final String phone;
  final String status;

  EmployeeModel({
    required this.empId,
    required this.empName,
    required this.role,
    required this.email,
    required this.phone,
    required this.status,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      empId: (json['empId'] ?? '').toString(),
      empName: (json['empName'] ?? '').toString(),
      role: RoleModel.fromJson(json['role'] as Map<String, dynamic>),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'empName': empName,
      'role': role.toJson(),
      'email': email,
      'phone': phone,
      'status': status,
    };
  }

  EmployeeModel copyWith({
    String? empId,
    String? empName,
    RoleModel? role,
    String? email,
    String? phone,
    String? status,
  }) {
    return EmployeeModel(
      empId: empId ?? this.empId,
      empName: empName ?? this.empName,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeModel &&
          runtimeType == other.runtimeType &&
          empId == other.empId &&
          empName == other.empName &&
          role == other.role &&
          email == other.email &&
          phone == other.phone &&
          status == other.status;

  @override
  int get hashCode =>
      empId.hashCode ^
      empName.hashCode ^
      role.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      status.hashCode;
}
