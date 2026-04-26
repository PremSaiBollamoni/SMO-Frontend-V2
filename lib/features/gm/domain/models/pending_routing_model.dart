/// Pending routing model for GM approval
class PendingRoutingModel {
  final int routingId;
  final int productId;
  final String productName;
  final int version;
  final String status;
  final String approvalStatus;
  final int stepsCount;
  final String? createdAt;
  final List<Map<String, dynamic>> operations;
  final List<Map<String, dynamic>> edges; // NEW: explicit edges from routing table

  PendingRoutingModel({
    required this.routingId,
    required this.productId,
    required this.productName,
    required this.version,
    required this.status,
    required this.approvalStatus,
    required this.stepsCount,
    this.createdAt,
    this.operations = const [],
    this.edges = const [],
  });

  factory PendingRoutingModel.fromJson(Map<String, dynamic> json) {
    // Get operations list - backend returns as List<dynamic> of Maps
    final operationsList = json['operations'] as List<dynamic>? ?? [];
    final operations = operationsList
        .map((op) => op is Map<String, dynamic> ? op : <String, dynamic>{})
        .toList();

    // Get edges list - backend returns as List<dynamic> of Maps
    final edgesList = json['edges'] as List<dynamic>? ?? [];
    final edges = edgesList
        .map((edge) => edge is Map<String, dynamic> ? edge : <String, dynamic>{})
        .toList();

    // Get product ID (backend returns snake_case)
    final productId = (json['product_id'] ?? json['productId']) as int? ?? 0;
    final productName = 'Product #$productId'; // Placeholder, will show ID

    return PendingRoutingModel(
      routingId: (json['routing_id'] ?? json['routingId']) as int? ?? 0,
      productId: productId,
      productName: productName,
      version: json['version'] as int? ?? 1,
      status: json['status'] as String? ?? 'DRAFT',
      approvalStatus: (json['approval_status'] ?? json['approvalStatus']) as String? ?? 'UNDER_REVIEW',
      stepsCount: operations.length,
      createdAt: json['approved_at'] ?? json['approvedAt'] as String?,
      operations: operations,
      edges: edges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routingId': routingId,
      'productId': productId,
      'productName': productName,
      'version': version,
      'status': status,
      'approval_status': approvalStatus,
      'stepsCount': stepsCount,
      'createdAt': createdAt,
      'operations': operations,
      'edges': edges,
    };
  }
}
