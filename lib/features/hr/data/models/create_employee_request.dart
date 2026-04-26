import '../../domain/models/role_model.dart';

/// Request model for creating an employee
class CreateEmployeeRequest {
  final String empId;
  final String empName;
  final RoleModel role;
  final String? dob;
  final String? phone;
  final String? address;
  final String email;
  final double? salary;
  final String? empDate;
  final String? bloodGroup;
  final String? emergencyContact;
  final String? aadharNumber;
  final String? panCardNumber;
  final String status;
  final String? password;

  CreateEmployeeRequest({
    required this.empId,
    required this.empName,
    required this.role,
    this.dob,
    this.phone,
    this.address,
    required this.email,
    this.salary,
    this.empDate,
    this.bloodGroup,
    this.emergencyContact,
    this.aadharNumber,
    this.panCardNumber,
    required this.status,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'empName': empName,
      'roleId': role.roleId
          .toString(), // Send roleId as string, not role object
      'dob': dob,
      'phone': phone,
      'address': address,
      'email': email,
      'salary': salary,
      'empDate': empDate,
      'bloodGroup': bloodGroup,
      'emergencyContact': emergencyContact,
      'aadharNumber': aadharNumber,
      'panCardNumber': panCardNumber,
      'status': status,
      'password': password,
    };
  }
}
