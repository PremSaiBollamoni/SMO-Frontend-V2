import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/button_model.dart';
import '../models/machine_model.dart';
import '../models/thread_model.dart';
import '../models/label_model.dart';
import '../models/style_model.dart';
import '../models/gtg_model.dart';

class MasterDataApiService {
  final Dio _dio = ApiClient().dio;

  // ==================== BUTTONS ====================

  Future<List<ButtonModel>> getAllButtons() async {
    try {
      final response = await _dio.get('/api/gm/masterdata/buttons');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ButtonModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ButtonModel>> getActiveButtons() async {
    try {
      final response = await _dio.get('/api/gm/masterdata/buttons/active');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ButtonModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createButton(ButtonModel button) async {
    try {
      final response = await _dio.post(
        '/api/gm/masterdata/buttons',
        data: button.toJson(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateButton(int id, ButtonModel button) async {
    try {
      final response = await _dio.put(
        '/api/gm/masterdata/buttons/$id',
        data: button.toJson(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteButton(int id) async {
    try {
      final response = await _dio.delete('/api/gm/masterdata/buttons/$id');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== MACHINES ====================

  Future<List<MachineModel>> getAllMachines() async {
    try {
      final response = await _dio.get('/api/gm/masterdata/machines');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MachineModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createMachine(MachineModel machine) async {
    try {
      final response = await _dio.post(
        '/api/gm/masterdata/machines',
        data: machine.toJson(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateMachine(int id, MachineModel machine) async {
    try {
      final response = await _dio.put(
        '/api/gm/masterdata/machines/$id',
        data: machine.toJson(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteMachine(int id) async {
    try {
      final response = await _dio.delete('/api/gm/masterdata/machines/$id');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== THREADS ====================

  Future<List<ThreadModel>> getAllThreads() async {
    try {
      final response = await _dio.get('/api/gm/masterdata/threads');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ThreadModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ThreadModel>> getActiveThreads() async {
    try {
      final response = await _dio.get('/api/gm/masterdata/threads/active');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ThreadModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createThread(ThreadModel thread) async {
    try {
      final response = await _dio.post(
        '/api/gm/masterdata/threads',
        data: thread.toJson(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateThread(int id, ThreadModel thread) async {
    try {
      final response = await _dio.put(
        '/api/gm/masterdata/threads/$id',
        data: thread.toJson(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteThread(int id) async {
    try {
      final response = await _dio.delete('/api/gm/masterdata/threads/$id');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== LABELS ====================

  Future<List<LabelModel>> getAllLabels() async {
    try {
      final response = await _dio.get('/api/gm/masterdata/labels');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => LabelModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createLabel(LabelModel label) async {
    try {
      final response = await _dio.post(
        '/api/gm/masterdata/labels',
        data: label.toJson(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateLabel(int id, LabelModel label) async {
    try {
      final response = await _dio.put(
        '/api/gm/masterdata/labels/$id',
        data: label.toJson(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteLabel(int id) async {
    try {
      final response = await _dio.delete('/api/gm/masterdata/labels/$id');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== STYLES ====================

  Future<List<StyleModel>> getAllStyles() async {
    try {
      final response = await _dio.get('/api/gm/masterdata/styles');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => StyleModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StyleModel>> getActiveStyles() async {
    try {
      final response = await _dio.get('/api/gm/masterdata/styles/active');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => StyleModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createStyle(StyleModel style) async {
    try {
      final response = await _dio.post(
        '/api/gm/masterdata/styles',
        data: style.toJson(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateStyle(int id, StyleModel style) async {
    try {
      final response = await _dio.put(
        '/api/gm/masterdata/styles/$id',
        data: style.toJson(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteStyle(int id) async {
    try {
      final response = await _dio.delete('/api/gm/masterdata/styles/$id');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== GTG ====================

  Future<List<GtgModel>> getAllGtgs() async {
    try {
      final response = await _dio.get('/api/gm/masterdata/gtg');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => GtgModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createGtg(GtgModel gtg) async {
    try {
      final response = await _dio.post(
        '/api/gm/masterdata/gtg',
        data: gtg.toJson(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateGtg(int id, GtgModel gtg) async {
    try {
      final response = await _dio.put(
        '/api/gm/masterdata/gtg/$id',
        data: gtg.toJson(),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteGtg(int id) async {
    try {
      final response = await _dio.delete('/api/gm/masterdata/gtg/$id');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
