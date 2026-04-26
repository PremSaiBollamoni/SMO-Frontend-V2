/// Request model for creating a product
class CreateProductRequest {
  final int productId;
  final String name;
  final String category;
  final String status;

  CreateProductRequest({
    required this.productId,
    required this.name,
    required this.category,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'category': category,
      'status': status,
    };
  }
}
