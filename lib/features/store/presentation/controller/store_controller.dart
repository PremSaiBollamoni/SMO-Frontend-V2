import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/repository/store_repository.dart';
import '../../domain/models/inventory_model.dart';
import '../../domain/models/stock_movement_model.dart';
import '../../domain/models/item_model.dart';
import '../../domain/models/grn_model.dart';

/// Store Controller - Manages store workspace state
class StoreController extends GetxController {
  final StoreRepository _repository;

  StoreController({StoreRepository? repository})
    : _repository = repository ?? StoreRepository();

  // Observable state
  final isLoading = false.obs;
  final employeeName = ''.obs;
  final empId = ''.obs;
  final role = ''.obs;

  // Inventory
  final inventory = <InventoryModel>[].obs;
  final loadingInventory = false.obs;

  // Stock Levels
  final stockLevels = <InventoryModel>[].obs;
  final loadingStockLevels = false.obs;

  // Stock Movements
  final stockMovements = <StockMovementModel>[].obs;
  final loadingMovements = false.obs;

  // Items
  final items = <ItemModel>[].obs;
  final loadingItems = false.obs;

  // GRNs
  final grns = <GrnModel>[].obs;
  final loadingGrns = false.obs;

  /// Initialize controller
  void initialize(String employeeId, String employeeName, String role) {
    empId.value = employeeId;
    this.employeeName.value = employeeName;
    this.role.value = role;
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      fetchInventory(),
      fetchStockLevels(),
      fetchMovements(),
      fetchItems(),
      fetchGrns(),
    ]);
  }

  /// Fetch inventory
  Future<void> fetchInventory() async {
    try {
      loadingInventory.value = true;
      final data = await _repository.getInventory();
      inventory.value = data;
    } catch (e) {
      debugPrint('Error fetching inventory: $e');
      rethrow;
    } finally {
      loadingInventory.value = false;
    }
  }

  /// Fetch stock levels
  Future<void> fetchStockLevels() async {
    try {
      loadingStockLevels.value = true;
      final data = await _repository.getStockLevels();
      stockLevels.value = data;
    } catch (e) {
      debugPrint('Error fetching stock levels: $e');
      rethrow;
    } finally {
      loadingStockLevels.value = false;
    }
  }

  /// Fetch stock movements
  Future<void> fetchMovements() async {
    try {
      loadingMovements.value = true;
      final data = await _repository.getStockMovements();
      stockMovements.value = data;
    } catch (e) {
      debugPrint('Error fetching movements: $e');
      rethrow;
    } finally {
      loadingMovements.value = false;
    }
  }

  /// Upsert inventory
  Future<bool> upsertInventory({
    required int itemId,
    required int qty,
    required String location,
    String? batch,
  }) async {
    try {
      isLoading.value = true;
      await _repository.upsertInventory(
        itemId: itemId,
        qty: qty,
        location: location,
        batch: batch,
      );
      await fetchInventory();
      await fetchStockLevels();
      await fetchMovements();
      return true;
    } catch (e) {
      debugPrint('Error upserting inventory: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Issue material
  Future<Map<String, dynamic>> issueMaterial({
    required int itemId,
    required int qty,
    required String location,
    int? bundleId,
  }) async {
    try {
      isLoading.value = true;
      final result = await _repository.issueMaterial(
        itemId: itemId,
        qty: qty,
        location: location,
        bundleId: bundleId,
      );
      await fetchInventory();
      await fetchStockLevels();
      await fetchMovements();
      return result;
    } catch (e) {
      debugPrint('Error issuing material: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch items
  Future<void> fetchItems() async {
    try {
      loadingItems.value = true;
      final data = await _repository.getItems();
      items.value = data;
    } catch (e) {
      debugPrint('Error fetching items: $e');
      rethrow;
    } finally {
      loadingItems.value = false;
    }
  }

  /// Create item
  Future<bool> createItem({
    required String name,
    String? type,
    String? category,
    String? unit,
  }) async {
    try {
      isLoading.value = true;
      await _repository.createItem(
        name: name,
        type: type,
        category: category,
        unit: unit,
      );
      await fetchItems();
      return true;
    } catch (e) {
      debugPrint('Error creating item: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch GRNs
  Future<void> fetchGrns() async {
    try {
      loadingGrns.value = true;
      final data = await _repository.getGrns();
      grns.value = data;
    } catch (e) {
      debugPrint('Error fetching GRNs: $e');
      rethrow;
    } finally {
      loadingGrns.value = false;
    }
  }

  /// Create GRN
  Future<bool> createGrn({int? poId}) async {
    try {
      isLoading.value = true;
      await _repository.createGrn(poId: poId);
      await fetchGrns();
      return true;
    } catch (e) {
      debugPrint('Error creating GRN: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
