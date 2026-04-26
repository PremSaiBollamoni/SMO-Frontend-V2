/// HR Dashboard statistics model
class HrDashboardModel {
  final int totalRoles;
  final int totalEmployees;

  HrDashboardModel({required this.totalRoles, required this.totalEmployees});

  factory HrDashboardModel.fromJson(Map<String, dynamic> json) {
    return HrDashboardModel(
      totalRoles: (json['totalRoles'] ?? 0) as int,
      totalEmployees: (json['totalEmployees'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'totalRoles': totalRoles, 'totalEmployees': totalEmployees};
  }

  HrDashboardModel copyWith({int? totalRoles, int? totalEmployees}) {
    return HrDashboardModel(
      totalRoles: totalRoles ?? this.totalRoles,
      totalEmployees: totalEmployees ?? this.totalEmployees,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HrDashboardModel &&
          runtimeType == other.runtimeType &&
          totalRoles == other.totalRoles &&
          totalEmployees == other.totalEmployees;

  @override
  int get hashCode => totalRoles.hashCode ^ totalEmployees.hashCode;
}
