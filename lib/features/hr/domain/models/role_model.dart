/// Role domain model
class RoleModel {
  final int roleId;
  final String roleName;
  final String activity;
  final String status;

  RoleModel({
    required this.roleId,
    required this.roleName,
    required this.activity,
    required this.status,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      roleId: int.tryParse(json['roleId']?.toString() ?? '0') ?? 0,
      roleName: (json['roleName'] ?? '').toString(),
      activity: (json['activity'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'roleName': roleName,
      'activity': activity,
      'status': status,
    };
  }

  RoleModel copyWith({
    int? roleId,
    String? roleName,
    String? activity,
    String? status,
  }) {
    return RoleModel(
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      activity: activity ?? this.activity,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleModel &&
          runtimeType == other.runtimeType &&
          roleId == other.roleId &&
          roleName == other.roleName &&
          activity == other.activity &&
          status == other.status;

  @override
  int get hashCode =>
      roleId.hashCode ^ roleName.hashCode ^ activity.hashCode ^ status.hashCode;
}
