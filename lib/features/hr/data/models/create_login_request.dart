/// Request model for creating/updating employee login credentials
class CreateLoginRequest {
  final String empId;
  final String password;
  final String status;

  CreateLoginRequest({
    required this.empId,
    required this.password,
    this.status = 'ACTIVE',
  });

  Map<String, dynamic> toJson() {
    return {
      'empId': empId,
      'password': password,
      'status': status,
    };
  }
}
