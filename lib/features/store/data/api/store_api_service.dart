import '../../../../core/network/api_client.dart';

/// Store API Service - Handles all store-related API calls
class StoreApiService {
  final ApiClient _apiClient;

  StoreApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get inventory
  Future<List<dynamic>> getInventory() async {
    final response = await _apiClient.dio.get('/api/store/inventory');
    return response.data as List<dynamic>;
  }

  /// Get stock levels
  Future<List<dynamic>> getStockLevels() async {
    final response = await _apiClient.dio.get('/api/store/stock-levels');
    return response.data as List<dynamic>;
  }

  /// Get stock movements
  Future<List<dynamic>> getStockMovements() async {
    final response = await _apiClient.dio.get('/api/store/stock-movements');
    return response.data as List<dynamic>;
  }

  /// Upsert inventory
  Future<Map<String, dynamic>> upsertInventory(
    Map<String, dynamic> body,
  ) async {
    final response = await _apiClient.dio.post(
      '/api/store/inventory',
      data: body,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Issue material
  Future<Map<String, dynamic>> issueMaterial(Map<String, dynamic> body) async {
    final response = await _apiClient.dio.post(
      '/api/store/issue-material',
      data: body,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get items
  Future<List<dynamic>> getItems() async {
    final response = await _apiClient.dio.get('/api/store/items');
    return response.data as List<dynamic>;
  }

  /// Create item
  Future<Map<String, dynamic>> createItem(Map<String, dynamic> body) async {
    final response = await _apiClient.dio.post('/api/store/items', data: body);
    return response.data as Map<String, dynamic>;
  }

  /// Get GRNs
  Future<List<dynamic>> getGrns() async {
    final response = await _apiClient.dio.get('/api/store/grn');
    return response.data as List<dynamic>;
  }

  /// Create GRN
  Future<Map<String, dynamic>> createGrn(Map<String, dynamic> body) async {
    final response = await _apiClient.dio.post('/api/store/grn', data: body);
    return response.data as Map<String, dynamic>;
  }
}
