import '../../domain/models/inventory_model.dart';
import '../../domain/models/stock_movement_model.dart';
import '../../domain/models/item_model.dart';
import '../../domain/models/grn_model.dart';
import '../api/store_api_service.dart';

/// Store Repository - Business logic layer for store operations
class StoreRepository {
  final StoreApiService _apiService;

  StoreRepository({StoreApiService? apiService})
    : _apiService = apiService ?? StoreApiService();

  /// Get inventory
  Future<List<InventoryModel>> getInventory() async {
    final data = await _apiService.getInventory();
    return data
        .whereType<Map>()
        .map((e) => InventoryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Get stock levels
  Future<List<InventoryModel>> getStockLevels() async {
    final data = await _apiService.getStockLevels();
    return data
        .whereType<Map>()
        .map((e) => InventoryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Get stock movements
  Future<List<StockMovementModel>> getStockMovements() async {
    final data = await _apiService.getStockMovements();
    return data
        .whereType<Map>()
        .map((e) => StockMovementModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Upsert inventory
  Future<String> upsertInventory({
    required int itemId,
    required int qty,
    required String location,
    String? batch,
  }) async {
    final body = {
      'itemId': itemId,
      'qty': qty,
      'location': location,
      'batch': batch,
    };
    await _apiService.upsertInventory(body);
    return 'Inventory updated';
  }

  /// Issue material
  Future<Map<String, dynamic>> issueMaterial({
    required int itemId,
    required int qty,
    required String location,
    int? bundleId,
  }) async {
    final body = {
      'itemId': itemId,
      'qty': qty,
      'location': location,
      'bundleId': bundleId,
    };
    return await _apiService.issueMaterial(body);
  }

  /// Get items
  Future<List<ItemModel>> getItems() async {
    final data = await _apiService.getItems();
    return data
        .whereType<Map>()
        .map((e) => ItemModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Create item
  Future<String> createItem({
    required String name,
    String? type,
    String? category,
    String? unit,
  }) async {
    final body = {
      'name': name,
      'type': type,
      'category': category,
      'unit': unit,
      'status': 'ACTIVE',
    };
    await _apiService.createItem(body);
    return 'Item created';
  }

  /// Get GRNs
  Future<List<GrnModel>> getGrns() async {
    final data = await _apiService.getGrns();
    return data
        .whereType<Map>()
        .map((e) => GrnModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Create GRN
  Future<String> createGrn({int? poId}) async {
    final body = {'poId': poId, 'status': 'RECEIVED'};
    await _apiService.createGrn(body);
    return 'GRN created';
  }
}
