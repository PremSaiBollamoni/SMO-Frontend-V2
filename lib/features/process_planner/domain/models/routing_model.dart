/// Routing domain model
class RoutingModel {
  final int routingId;
  final int productId;
  final int version;
  final String status;
  final String approvalStatus;

  RoutingModel({
    required this.routingId,
    required this.productId,
    required this.version,
    required this.status,
    required this.approvalStatus,
  });

  factory RoutingModel.fromJson(Map<String, dynamic> json) {
    return RoutingModel(
      routingId: json['routingId'] as int,
      productId: json['productId'] as int,
      version: json['version'] as int? ?? 1,
      status: json['status'] as String? ?? 'ACTIVE',
      approvalStatus: json['approvalStatus'] as String? ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routingId': routingId,
      'productId': productId,
      'version': version,
      'status': status,
      'approvalStatus': approvalStatus,
    };
  }
}
