/// Order model for production orders
class OrderModel {
  final int? orderId;
  final String orderNumber;
  final int productId;
  final int routingId;
  final int orderQty;
  final String? productionStartDate;
  final String? expectedCompletionDate;
  final String? customerName;
  final String status;
  final int createdBy;
  final String? createdAt;
  final String? updatedAt;
  
  // Additional fields from API responses
  final String? productName;
  final int? completed;
  final int? pending;
  final double? progressPercent;
  final String? avgTimePerUnit;

  OrderModel({
    this.orderId,
    required this.orderNumber,
    required this.productId,
    required this.routingId,
    required this.orderQty,
    this.productionStartDate,
    this.expectedCompletionDate,
    this.customerName,
    required this.status,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.productName,
    this.completed,
    this.pending,
    this.progressPercent,
    this.avgTimePerUnit,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] is int ? json['order_id'] : null,
      orderNumber: json['order_number'] ?? json['order_id'] ?? '',
      productId: json['product_id'] ?? 0,
      routingId: json['routing_id'] ?? 0,
      orderQty: json['order_qty'] ?? 0,
      productionStartDate: json['production_start_date'],
      expectedCompletionDate: json['expected_completion_date'],
      customerName: json['customer_name'],
      status: json['status'] ?? 'DRAFT',
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      productName: json['product_name'],
      completed: json['completed'],
      pending: json['pending'],
      progressPercent: json['progress_percent']?.toDouble(),
      avgTimePerUnit: json['avg_time_per_unit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (orderId != null) 'order_id': orderId,
      'order_number': orderNumber,
      'product_id': productId,
      'routing_id': routingId,
      'order_qty': orderQty,
      if (productionStartDate != null) 'production_start_date': productionStartDate,
      if (expectedCompletionDate != null) 'expected_completion_date': expectedCompletionDate,
      if (customerName != null) 'customer_name': customerName,
      'status': status,
      'created_by': createdBy,
    };
  }

  OrderModel copyWith({
    int? orderId,
    String? orderNumber,
    int? productId,
    int? routingId,
    int? orderQty,
    String? productionStartDate,
    String? expectedCompletionDate,
    String? customerName,
    String? status,
    int? createdBy,
    String? productName,
    int? completed,
    int? pending,
    double? progressPercent,
    String? avgTimePerUnit,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      productId: productId ?? this.productId,
      routingId: routingId ?? this.routingId,
      orderQty: orderQty ?? this.orderQty,
      productionStartDate: productionStartDate ?? this.productionStartDate,
      expectedCompletionDate: expectedCompletionDate ?? this.expectedCompletionDate,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      productName: productName ?? this.productName,
      completed: completed ?? this.completed,
      pending: pending ?? this.pending,
      progressPercent: progressPercent ?? this.progressPercent,
      avgTimePerUnit: avgTimePerUnit ?? this.avgTimePerUnit,
    );
  }
}
