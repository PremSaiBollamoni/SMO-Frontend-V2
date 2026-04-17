import '../api/hr_api_service.dart';
import '../models/create_role_request.dart';
import '../models/create_employee_request.dart';
import '../models/create_login_request.dart';
import '../../domain/models/role_model.dart';
import '../../domain/models/employee_model.dart';
import '../../domain/models/employee_profile_model.dart';
import '../../domain/models/hr_dashboard_model.dart';

/// HR Repository - Implements business logic and data access patterns
class HrRepository {
  final HrApiService _apiService;

  HrRepository({HrApiService? apiService})
      : _apiService = apiService ?? HrApiService();

  /// Fetch all roles
  Future<List<RoleModel>> getRoles(String actorEmpId) async {
    return await _apiService.fetchRoles(actorEmpId);
  }

  /// Fetch all employees
  Future<List<EmployeeModel>> getEmployees(String actorEmpId) async {
    return await _apiService.fetchEmployees(actorEmpId);
  }

  /// Fetch employee profile
  Future<EmployeeProfileModel> getEmployeeProfile(
    String empId,
    String actorEmpId,
  ) async {
    return await _apiService.fetchEmployeeProfile(empId, actorEmpId);
  }

  /// Get HR dashboard statistics
  /// Calculates from existing data (no dedicated backend endpoint)
  Future<HrDashboardModel> getDashboard(
    String actorEmpId,
  ) async {
    try {
      final roles = await getRoles(actorEmpId);
      final employees = await getEmployees(actorEmpId);

      return HrDashboardModel(
        totalRoles: roles.length,
        totalEmployees: employees.length,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new role
  Future<void> createRole({
    required int roleId,
    required String roleName,
    required String activity,
    required String status,
  }) async {
    final request = CreateRoleRequest(
      roleId: roleId,
      roleName: roleName,
      activity: activity,
      status: status,
    );
    return await _apiService.createRole(request);
  }

  /// Create a new employee
  Future<Map<String, dynamic>> createEmployee({
    required String empId,
    required String empName,
    required RoleModel role,
    String? dob,
    String? phone,
    String? address,
    required String email,
    double? salary,
    String? empDate,
    String? bloodGroup,
    String? emergencyContact,
    String? aadharNumber,
    String? panCardNumber,
    required String status,
    String? password,
  }) async {
    final request = CreateEmployeeRequest(
      empId: empId,
      empName: empName,
      role: role,
      dob: dob,
      phone: phone,
      address: address,
      email: email,
      salary: salary,
      empDate: empDate,
      bloodGroup: bloodGroup,
      emergencyContact: emergencyContact,
      aadharNumber: aadharNumber,
      panCardNumber: panCardNumber,
      status: status,
      password: password,
    );
    return await _apiService.createEmployee(request);
  }

  /// Create employee login credentials
  Future<void> createEmployeeLogin({
    required String empId,
    required String password,
  }) async {
    final request = CreateLoginRequest(
      empId: empId,
      password: password,
    );
    return await _apiService.createEmployeeLogin(request);
  }

  /// Update employee profile
  Future<void> updateEmployee({
    required String empId,
    required String empName,
    required RoleModel role,
    String? dob,
    String? phone,
    String? address,
    required String email,
    double? salary,
    String? empDate,
    String? bloodGroup,
    String? emergencyContact,
    String? aadharNumber,
    String? panCardNumber,
    required String status,
    String? password,
  }) async {
    final request = CreateEmployeeRequest(
      empId: empId,
      empName: empName,
      role: role,
      dob: dob,
      phone: phone,
      address: address,
      email: email,
      salary: salary,
      empDate: empDate,
      bloodGroup: bloodGroup,
      emergencyContact: emergencyContact,
      aadharNumber: aadharNumber,
      panCardNumber: panCardNumber,
      status: status,
      password: password,
    );
    return await _apiService.updateEmployee(empId, request);
  }

  /// Update employee login credentials
  Future<void> updateEmployeeLogin({
    required String empId,
    required String password,
  }) async {
    final request = CreateLoginRequest(
      empId: empId,
      password: password,
    );
    return await _apiService.updateEmployeeLogin(empId, request);
  }
}
