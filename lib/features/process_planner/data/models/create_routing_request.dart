/// Request model for creating a routing
class CreateRoutingRequest {
  final int routingId;
  final int productId;
  final int version;
  final String status;
  final String approvalStatus;

  CreateRoutingRequest({
    required this.routingId,
    required this.productId,
    required this.version,
    required this.status,
    required this.approvalStatus,
  });

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
