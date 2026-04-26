/// Item Model
class ItemModel {
  final int? itemId;
  final String? name;
  final String? type;
  final String? category;
  final String? unit;
  final String? status;

  ItemModel({
    this.itemId,
    this.name,
    this.type,
    this.category,
    this.unit,
    this.status,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      itemId: json['itemId'] as int?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      category: json['category'] as String?,
      unit: json['unit'] as String?,
      status: json['status'] as String?,
    );
  }
}
