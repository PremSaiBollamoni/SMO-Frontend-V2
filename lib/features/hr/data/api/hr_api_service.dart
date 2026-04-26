import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../models/create_role_request.dart';
import '../models/create_employee_request.dart';
import '../models/create_login_request.dart';
import '../../domain/models/role_model.dart';
import '../../domain/models/employee_model.dart';
import '../../domain/models/employee_profile_model.dart';

/// HR API Service - Handles all HR-related API calls
/// CRITICAL: All endpoints and query parameters MUST remain exactly the same
class HrApiService {
  final Dio _dio;

  HrApiService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  /// Fetch all roles
  /// Endpoint: GET /api/hr/roles?actorEmpId={empId}
  Future<List<RoleModel>> fetchRoles(String actorEmpId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.hrRoles,
        queryParameters: {QueryParams.actorEmpId: actorEmpId},
      );

      if (response.statusCode == 200) {
        final list = (response.data as List<dynamic>)
            .map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      }
      throw Exception('Failed to fetch roles: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch all employees
  /// Endpoint: GET /api/hr/employees?actorEmpId={empId}
  Future<List<EmployeeModel>> fetchEmployees(String actorEmpId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.hrEmployees,
        queryParameters: {QueryParams.actorEmpId: actorEmpId},
      );

      if (response.statusCode == 200) {
        final list = (response.data as List<dynamic>)
            .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      }
      throw Exception('Failed to fetch employees: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch employee profile by ID
  /// Endpoint: GET /api/hr/employees/{empId}?actorEmpId={actorEmpId}
  Future<EmployeeProfileModel> fetchEmployeeProfile(
    String empId,
    String actorEmpId,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.hrEmployeeDetail}/$empId',
        queryParameters: {QueryParams.actorEmpId: actorEmpId},
      );

      if (response.statusCode == 200) {
        return EmployeeProfileModel.fromJson(response.data);
      }
      throw Exception(
        'Failed to fetch employee profile: ${response.statusCode}',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new role
  /// Endpoint: POST /api/hr/roles
  /// Request body: CreateRoleRequest.toJson()
  Future<void> createRole(CreateRoleRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.hrRoles,
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create role: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new employee
  /// Endpoint: POST /api/hr/employees
  /// Request body: CreateEmployeeRequest.toJson()
  Future<Map<String, dynamic>> createEmployee(
    CreateEmployeeRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.hrEmployees,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to create employee: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  /// Create employee login credentials
  /// Endpoint: POST /api/hr/login
  /// Request body: CreateLoginRequest.toJson()
  Future<void> createEmployeeLogin(CreateLoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.hrLogin,
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Failed to create employee login: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update employee profile
  /// Endpoint: PUT /api/hr/employees/{empId}
  /// Request body: CreateEmployeeRequest.toJson()
  Future<void> updateEmployee(
    String empId,
    CreateEmployeeRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.hrEmployeeDetail}/$empId',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update employee: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Update employee login credentials
  /// Endpoint: PUT /api/hr/login/{empId}
  /// Request body: CreateLoginRequest.toJson()
  Future<void> updateEmployeeLogin(
    String empId,
    CreateLoginRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.hrLoginUpdate}/$empId',
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update employee login: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an employee
  /// Endpoint: DELETE /api/hr/employees/{empId}
  Future<void> deleteEmployee(String empId) async {
    try {
      final response = await _dio.delete(
        '${ApiEndpoints.hrEmployeeDetail}/$empId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete employee: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete multiple employees
  /// Endpoint: DELETE /api/hr/employees (with empIds in body)
  /// Fallback: Individual deletion if bulk fails
  Future<void> deleteEmployees(List<String> empIds) async {
    try {
      debugPrint('=== Bulk Delete Employees ===');
      debugPrint('Employee IDs: $empIds');
      debugPrint('Request body: ${{'empIds': empIds}}');

      final response = await _dio.delete(
        ApiEndpoints.hrEmployees,
        data: {'empIds': empIds},
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete employees: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('=== Bulk Delete Error - Trying Fallback ===');
      debugPrint('Error: ${e.message}');
      debugPrint('Status Code: ${e.response?.statusCode}');

      // If bulk delete fails with 500 or 404, try deleting one by one
      if (e.response?.statusCode == 500 || e.response?.statusCode == 404) {
        debugPrint('=== Fallback: Deleting employees individually ===');

        int successCount = 0;
        int failCount = 0;

        for (final empId in empIds) {
          try {
            await deleteEmployee(empId);
            successCount++;
            debugPrint('✓ Deleted employee: $empId');
          } catch (individualError) {
            failCount++;
            debugPrint(
              '✗ Failed to delete employee: $empId - $individualError',
            );
          }
        }

        debugPrint(
          '=== Fallback Complete: $successCount succeeded, $failCount failed ===',
        );

        if (failCount > 0 && successCount == 0) {
          throw Exception('Failed to delete all employees');
        }

        // If at least some succeeded, consider it a partial success
        return;
      }

      rethrow;
    } catch (e) {
      debugPrint('=== Bulk Delete Error ===');
      debugPrint('Error: $e');
      rethrow;
    }
  }

  /// Delete a role
  /// Endpoint: DELETE /api/hr/roles/{roleId}
  Future<void> deleteRole(int roleId) async {
    try {
      debugPrint('=== Delete Role ===');
      debugPrint('Role ID: $roleId');

      final response = await _dio.delete('${ApiEndpoints.hrRoles}/$roleId');

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete role: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('=== Delete Role Error ===');
      debugPrint('Error: $e');
      rethrow;
    }
  }

  /// Delete multiple roles
  /// Endpoint: DELETE /api/hr/roles (with roleIds in body)
  /// Fallback: Individual deletion if bulk fails
  Future<void> deleteRoles(List<int> roleIds) async {
    try {
      debugPrint('=== Bulk Delete Roles ===');
      debugPrint('Role IDs: $roleIds');
      debugPrint('Request body: ${{'roleIds': roleIds}}');

      final response = await _dio.delete(
        ApiEndpoints.hrRoles,
        data: {'roleIds': roleIds},
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete roles: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('=== Bulk Delete Roles Error - Trying Fallback ===');
      debugPrint('Error: ${e.message}');
      debugPrint('Status Code: ${e.response?.statusCode}');

      // If bulk delete fails with 500 or 404, try deleting one by one
      if (e.response?.statusCode == 500 || e.response?.statusCode == 404) {
        debugPrint('=== Fallback: Deleting roles individually ===');

        int successCount = 0;
        int failCount = 0;

        for (final roleId in roleIds) {
          try {
            await deleteRole(roleId);
            successCount++;
            debugPrint('✓ Deleted role: $roleId');
          } catch (individualError) {
            failCount++;
            debugPrint('✗ Failed to delete role: $roleId - $individualError');
          }
        }

        debugPrint(
          '=== Fallback Complete: $successCount succeeded, $failCount failed ===',
        );

        if (failCount > 0 && successCount == 0) {
          throw Exception('Failed to delete all roles');
        }

        // If at least some succeeded, consider it a partial success
        return;
      }

      rethrow;
    } catch (e) {
      debugPrint('=== Bulk Delete Roles Error ===');
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
