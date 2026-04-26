/// Stock Movement Model
class StockMovementModel {
  final int? movementId;
  final int? itemId;
  final String? type;
  final int? qty;
  final String? timestamp;

  StockMovementModel({
    this.movementId,
    this.itemId,
    this.type,
    this.qty,
    this.timestamp,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      movementId: json['movementId'] as int?,
      itemId: json['itemId'] as int?,
      type: json['type'] as String?,
      qty: json['qty'] as int?,
      timestamp: json['timestamp'] as String?,
    );
  }
}
