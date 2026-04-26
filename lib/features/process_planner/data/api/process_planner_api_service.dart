import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/create_product_request.dart';
import '../models/create_operation_request.dart';
import '../models/create_routing_request.dart';
import '../models/create_routing_step_request.dart';
import '../../domain/models/product_model.dart';
import '../../domain/models/operation_model.dart';
import '../../domain/models/routing_model.dart';
import '../../domain/models/routing_step_model.dart';

/// Process Planner API Service - Handles all process planning API calls
class ProcessPlannerApiService {
  final Dio _dio;

  ProcessPlannerApiService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ── Products ──────────────────────────────────────────────────────────────

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await _dio.get('/api/production/products');
      if (response.statusCode == 200) {
        final list = (response.data as List<dynamic>)
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      }
      throw Exception('Failed to fetch products: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createProduct(CreateProductRequest request) async {
    try {
      final response = await _dio.post(
        '/api/production/products',
        data: request.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      final response = await _dio.delete('/api/production/products/$productId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── Operations ────────────────────────────────────────────────────────────

  Future<List<OperationModel>> fetchOperations() async {
    try {
      final response = await _dio.get('/api/production/operations');
      if (response.statusCode == 200) {
        final list = (response.data as List<dynamic>)
            .map((e) => OperationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      }
      throw Exception('Failed to fetch operations: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createOperation(CreateOperationRequest request) async {
    try {
      final response = await _dio.post(
        '/api/production/operations',
        data: request.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create operation: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteOperation(int operationId) async {
    try {
      final response = await _dio.delete(
        '/api/production/operations/$operationId',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete operation: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── Routings ──────────────────────────────────────────────────────────────

  Future<List<RoutingModel>> fetchRoutings() async {
    try {
      final response = await _dio.get('/api/production/routings');
      if (response.statusCode == 200) {
        final list = (response.data as List<dynamic>)
            .map((e) => RoutingModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      }
      throw Exception('Failed to fetch routings: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createRouting(CreateRoutingRequest request) async {
    try {
      final response = await _dio.post(
        '/api/production/routings',
        data: request.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create routing: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRouting(int routingId) async {
    try {
      final response = await _dio.delete('/api/production/routings/$routingId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete routing: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── Routing Steps ─────────────────────────────────────────────────────────

  Future<List<RoutingStepModel>> fetchRoutingSteps(int routingId) async {
    try {
      final response = await _dio.get(
        '/api/production/routingsteps/routing/$routingId',
      );
      if (response.statusCode == 200) {
        final list = (response.data as List<dynamic>)
            .map((e) => RoutingStepModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      }
      throw Exception('Failed to fetch routing steps: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createRoutingStep(CreateRoutingStepRequest request) async {
    try {
      final response = await _dio.post(
        '/api/production/routingsteps',
        data: request.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to create routing step: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRoutingStep(int routingStepId) async {
    try {
      final response = await _dio.delete(
        '/api/production/routingsteps/$routingStepId',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to delete routing step: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // ── Process Plan Draft ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> submitProcessPlanDraft(
    int productId,
    List<Map<String, dynamic>> steps,
  ) async {
    try {
      final response = await _dio.post(
        '/api/processplan/draft',
        queryParameters: {'productId': productId},
        data: steps,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to submit process plan: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
