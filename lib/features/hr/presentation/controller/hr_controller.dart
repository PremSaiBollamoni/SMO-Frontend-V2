import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/repository/hr_repository.dart';
import '../../domain/models/role_model.dart';
import '../../domain/models/employee_model.dart';
import '../../domain/models/employee_profile_model.dart';
import '../../domain/models/hr_dashboard_model.dart';

/// HR Controller - Manages HR feature state with GetX
class HrController extends GetxController {
  final HrRepository _repository;

  HrController({HrRepository? repository})
    : _repository = repository ?? HrRepository();

  // Observable state
  final isLoading = false.obs;
  final employeeName = ''.obs;
  final empId = ''.obs;
  final dashboard = Rx<HrDashboardModel?>(null);
  final roles = <RoleModel>[].obs;
  final employees = <EmployeeModel>[].obs;
  final currentProfile = Rx<EmployeeProfileModel?>(null);

  // Role management
  final roleSearchQuery = ''.obs;
  final roleStatusFilter = 'ALL'.obs;
  final selectedRoleIds = <String>{}.obs;
  final selectVisibleRoles = false.obs;

  // Employee management
  final employeeSearchQuery = ''.obs;
  final employeeRoleFilter = 'ALL'.obs;
  final selectedEmployeeIds = <String>{}.obs;
  final selectVisibleEmployees = false.obs;

  // Profile edit mode
  final isProfileEditMode = false.obs;

  /// Initialize controller with employee ID
  void initialize(String employeeId, String employeeName) {
    empId.value = employeeId;
    this.employeeName.value = employeeName;
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      fetchDashboard(),
      fetchRoles(),
      fetchEmployees(),
      fetchProfile(),
    ]);
  }

  /// Fetch dashboard statistics
  Future<void> fetchDashboard() async {
    try {
      final data = await _repository.getDashboard(empId.value);
      dashboard.value = data;
    } catch (e) {
      debugPrint('Error fetching dashboard: $e');
    }
  }

  /// Fetch all roles
  Future<void> fetchRoles() async {
    try {
      final data = await _repository.getRoles(empId.value);
      roles.value = data;
    } catch (e) {
      debugPrint('Error fetching roles: $e');
    }
  }

  /// Fetch all employees
  Future<void> fetchEmployees() async {
    try {
      final data = await _repository.getEmployees(empId.value);
      employees.value = data;
    } catch (e) {
      debugPrint('Error fetching employees: $e');
    }
  }

  /// Fetch current user profile
  Future<void> fetchProfile() async {
    try {
      final data = await _repository.getEmployeeProfile(
        empId.value,
        empId.value,
      );
      currentProfile.value = data;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  /// Fetch specific employee profile
  Future<EmployeeProfileModel?> fetchEmployeeProfile(String employeeId) async {
    try {
      return await _repository.getEmployeeProfile(employeeId, empId.value);
    } catch (e) {
      debugPrint('Error fetching employee profile: $e');
      return null;
    }
  }

  /// Create a new role
  Future<bool> createRole({
    required int roleId,
    required String roleName,
    required String activity,
    required String status,
  }) async {
    try {
      isLoading.value = true;
      await _repository.createRole(
        roleId: roleId,
        roleName: roleName,
        activity: activity,
        status: status,
      );
      await fetchRoles();
      await fetchDashboard();
      return true;
    } catch (e) {
      debugPrint('Error creating role: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a new employee
  /// Note: Backend automatically creates login credentials when employee is created
  Future<Map<String, dynamic>?> createEmployee({
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
    required String password,
  }) async {
    try {
      isLoading.value = true;
      final result = await _repository.createEmployee(
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
        status: 'ACTIVE',
        password: password,
      );

      await fetchEmployees();
      await fetchDashboard();
      return result;
    } catch (e) {
      debugPrint('Error creating employee: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update current user profile
  Future<bool> updateProfile({
    required String empName,
    required String email,
    String? phone,
    String? address,
    String? dob,
    String? bloodGroup,
    String? emergencyContact,
    String? aadharNumber,
    String? panCardNumber,
    required String status,
    String? password,
  }) async {
    try {
      isLoading.value = true;

      // Get current profile to preserve role
      final profile = currentProfile.value;
      if (profile == null) return false;

      await _repository.updateEmployee(
        empId: empId.value,
        empName: empName,
        role: profile.role,
        email: email,
        phone: phone,
        address: address,
        dob: dob,
        bloodGroup: bloodGroup,
        emergencyContact: emergencyContact,
        aadharNumber: aadharNumber,
        panCardNumber: panCardNumber,
        status: status,
        empDate: '2024-01-01', // Fallback
      );

      // Update password if provided
      if (password != null && password.isNotEmpty) {
        await _repository.updateEmployeeLogin(
          empId: empId.value,
          password: password,
        );
      }

      await fetchProfile();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get filtered roles based on search and status filter
  List<RoleModel> get filteredRoles {
    final query = roleSearchQuery.value.trim().toLowerCase();
    return roles.where((r) {
      final queryMatch =
          query.isEmpty ||
          r.roleName.toLowerCase().contains(query) ||
          r.activity.toLowerCase().contains(query) ||
          r.roleId.toString().contains(query);
      final statusMatch =
          roleStatusFilter.value == 'ALL' ||
          r.status.toUpperCase() == roleStatusFilter.value.toUpperCase();
      return queryMatch && statusMatch;
    }).toList();
  }

  /// Get filtered employees based on search and role filter
  List<EmployeeModel> get filteredEmployees {
    final query = employeeSearchQuery.value.trim().toLowerCase();
    return employees.where((e) {
      final queryMatch =
          query.isEmpty ||
          e.empName.toLowerCase().contains(query) ||
          e.email.toLowerCase().contains(query) ||
          e.empId.toString().contains(query);
      final roleMatch =
          employeeRoleFilter.value == 'ALL' ||
          e.role.roleName.toLowerCase() ==
              employeeRoleFilter.value.toLowerCase();
      return queryMatch && roleMatch;
    }).toList();
  }

  /// Toggle role selection
  void toggleRoleSelection(String roleId) {
    if (selectedRoleIds.contains(roleId)) {
      selectedRoleIds.remove(roleId);
    } else {
      selectedRoleIds.add(roleId);
    }
  }

  /// Toggle employee selection
  void toggleEmployeeSelection(String employeeId) {
    if (selectedEmployeeIds.contains(employeeId)) {
      selectedEmployeeIds.remove(employeeId);
    } else {
      selectedEmployeeIds.add(employeeId);
    }
  }

  /// Clear role selections
  void clearRoleSelections() {
    selectedRoleIds.clear();
    selectVisibleRoles.value = false;
  }

  /// Clear employee selections
  void clearEmployeeSelections() {
    selectedEmployeeIds.clear();
    selectVisibleEmployees.value = false;
  }

  /// Toggle profile edit mode
  void toggleProfileEditMode() {
    isProfileEditMode.value = !isProfileEditMode.value;
  }

  /// Delete a single employee
  Future<bool> deleteEmployee(String empId) async {
    try {
      isLoading.value = true;
      await _repository.deleteEmployee(empId);
      await fetchEmployees();
      await fetchDashboard();
      return true;
    } catch (e) {
      debugPrint('Error deleting employee: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete multiple employees
  Future<bool> deleteEmployees(List<String> empIds) async {
    try {
      isLoading.value = true;
      debugPrint('=== Controller: Deleting ${empIds.length} employees ===');
      debugPrint('Employee IDs: $empIds');

      await _repository.deleteEmployees(empIds);
      clearEmployeeSelections();
      await fetchEmployees();
      await fetchDashboard();

      debugPrint('=== Controller: Deletion successful ===');
      return true;
    } catch (e) {
      debugPrint('=== Controller: Error deleting employees ===');
      debugPrint('Error: $e');

      // Check if it's a partial success (some deleted via fallback)
      if (e.toString().contains('Failed to delete all employees')) {
        // Refresh data anyway since some might have been deleted
        clearEmployeeSelections();
        await fetchEmployees();
        await fetchDashboard();
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a single role
  Future<bool> deleteRole(int roleId) async {
    try {
      isLoading.value = true;
      debugPrint('=== Controller: Deleting role $roleId ===');

      await _repository.deleteRole(roleId);
      await fetchRoles();
      await fetchDashboard();

      debugPrint('=== Controller: Role deletion successful ===');
      return true;
    } catch (e) {
      debugPrint('=== Controller: Error deleting role ===');
      debugPrint('Error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete multiple roles
  Future<bool> deleteRoles(List<int> roleIds) async {
    try {
      isLoading.value = true;
      debugPrint('=== Controller: Deleting ${roleIds.length} roles ===');
      debugPrint('Role IDs: $roleIds');

      await _repository.deleteRoles(roleIds);
      clearRoleSelections();
      await fetchRoles();
      await fetchDashboard();

      debugPrint('=== Controller: Bulk role deletion successful ===');
      return true;
    } catch (e) {
      debugPrint('=== Controller: Error deleting roles ===');
      debugPrint('Error: $e');

      // Check if it's a partial success (some deleted via fallback)
      if (e.toString().contains('Failed to delete all roles')) {
        // Refresh data anyway since some might have been deleted
        clearRoleSelections();
        await fetchRoles();
        await fetchDashboard();
      }

      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
