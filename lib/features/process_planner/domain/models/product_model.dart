/// Product domain model
class ProductModel {
  final int productId;
  final String name;
  final String category;
  final String status;

  ProductModel({
    required this.productId,
    required this.name,
    required this.category,
    required this.status,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'] as int,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'category': category,
      'status': status,
    };
  }
}
