/// Inventory Model
class InventoryModel {
  final int? stockId;
  final int? itemId;
  final int? qty;
  final String? location;
  final String? batch;

  InventoryModel({
    this.stockId,
    this.itemId,
    this.qty,
    this.location,
    this.batch,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      stockId: json['stockId'] as int?,
      itemId: json['itemId'] as int?,
      qty: json['qty'] as int?,
      location: json['location'] as String?,
      batch: json['batch'] as String?,
    );
  }
}
