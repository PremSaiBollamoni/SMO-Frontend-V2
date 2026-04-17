/// Request model for creating a role
class CreateRoleRequest {
  final int roleId;
  final String roleName;
  final String activity;
  final String status;

  CreateRoleRequest({
    required this.roleId,
    required this.roleName,
    required this.activity,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'roleName': roleName,
      'activity': activity,
      'status': status,
    };
  }
}
