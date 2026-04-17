/// Role response model from authentication
class RoleResponse {
  final String role;
  final String employeeName;
  final String empId;

  RoleResponse({
    required this.role,
    required this.employeeName,
    required this.empId,
  });

  factory RoleResponse.fromJson(Map<String, dynamic> json) {
    return RoleResponse(
      role: (json['role'] ?? '').toString(),
      employeeName: (json['employeeName'] ?? '').toString(),
      empId: (json['empId'] ?? '').toString(),
    );
  }
}
