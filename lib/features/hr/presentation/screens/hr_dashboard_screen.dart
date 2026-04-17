import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../login_screen.dart';
import '../controller/hr_controller.dart';
import '../widgets/hr_sidebar.dart';
import '../widgets/hr_top_bar.dart';
import '../widgets/dashboard_view.dart';
import '../widgets/roles_view.dart';
import '../widgets/employees_view.dart';
import '../widgets/profile_view.dart';
import '../widgets/create_role_dialog.dart';
import '../widgets/create_employee_dialog.dart';
import '../../domain/models/employee_profile_model.dart';

/// HR Dashboard Screen - Clean Architecture Implementation
class HrDashboardScreen extends StatefulWidget {
  final Function(bool)? setDarkMode;

  const HrDashboardScreen({super.key, this.setDarkMode});

  @override
  State<HrDashboardScreen> createState() => _HrDashboardScreenState();
}

class _HrDashboardScreenState extends State<HrDashboardScreen> {
  final HrController _controller = Get.put(HrController());
  int _selectedMenu = 0;
  bool _isSidebarVisible = false; // Start with sidebar closed

  @override
  void initState() {
    super.initState();
    _loadSessionAndData();
  }

  Future<void> _loadSessionAndData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeName = prefs.getString('EMPLOYEE_NAME') ?? 'HR';
      final empId = prefs.getString('EMP_ID') ?? '1001';

      debugPrint('=== Loading Session ===');
      debugPrint('Employee Name: $employeeName');
      debugPrint('Employee ID: $empId');

      // Initialize API client with employee ID
      ApiClient().setEmpId(empId);
      
      _controller.initialize(empId, employeeName);
      await _controller.refreshAll();
      
      debugPrint('=== Session Loaded Successfully ===');
    } catch (e) {
      debugPrint('=== Session Load Error ===');
      debugPrint('Error: $e');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginScreen(setDarkMode: widget.setDarkMode),
      ),
      (route) => false,
    );
  }

  Future<void> _showEmployeeProfile(String empId) async {
    final profile = await _controller.fetchEmployeeProfile(empId);
    if (profile == null || !mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => _buildEmployeeProfileDialog(profile),
    );
  }

  Widget _buildEmployeeProfileDialog(EmployeeProfileModel profile) {
    return AlertDialog(
      title: Text('Profile - ${profile.empName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee ID: ${profile.empId}'),
            const SizedBox(height: 6),
            Text('Name: ${profile.empName}'),
            const SizedBox(height: 6),
            Text('Role: ${profile.role.roleName}'),
            const SizedBox(height: 6),
            Text('Email: ${profile.email}'),
            const SizedBox(height: 6),
            Text('Phone: ${profile.phone.isEmpty ? '-' : profile.phone}'),
            const SizedBox(height: 6),
            Text('Address: ${profile.address.isEmpty ? '-' : profile.address}'),
            const SizedBox(height: 6),
            Text('DOB: ${profile.dob.isEmpty ? '-' : profile.dob}'),
            const SizedBox(height: 6),
            Text('Blood Group: ${profile.bloodGroup.isEmpty ? '-' : profile.bloodGroup}'),
            const SizedBox(height: 6),
            Text('Emergency Contact: ${profile.emergencyContact.isEmpty ? '-' : profile.emergencyContact}'),
            const SizedBox(height: 6),
            Text('Aadhar: ${profile.aadharNumber.isEmpty ? '-' : profile.aadharNumber}'),
            const SizedBox(height: 6),
            Text('PAN: ${profile.panCardNumber.isEmpty ? '-' : profile.panCardNumber}'),
            const SizedBox(height: 6),
            Text('Status: ${profile.status}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _getPageTitle() {
    switch (_selectedMenu) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Roles Management';
      case 2:
        return 'Employees Management';
      case 3:
        return 'My Profile';
      default:
        return 'HR Dashboard';
    }
  }

  Future<void> _showCreateRoleDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => CreateRoleDialog(
        onCreateRole: ({
          required int roleId,
          required String roleName,
          required String activity,
          required String status,
        }) async {
          final success = await _controller.createRole(
            roleId: roleId,
            roleName: roleName,
            activity: activity,
            status: status,
          );

          if (!mounted) return;
          if (success) {
            CustomSnackbar.showSuccess(context, 'Role created');
          } else {
            CustomSnackbar.showError(context, 'Role creation failed');
          }
        },
      ),
    );
  }

  Future<void> _showCreateEmployeeDialog() async {
    final roles = _controller.roles.toList();
    
    if (roles.isEmpty) {
      CustomSnackbar.showError(context, 'Create at least one role first');
      return;
    }

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => CreateEmployeeDialog(
        roles: roles,
        onCreateEmployee: ({
          required String empId,
          required String empName,
          required role,
          dob,
          phone,
          address,
          required String email,
          salary,
          empDate,
          bloodGroup,
          emergencyContact,
          aadharNumber,
          panCardNumber,
          required String password,
        }) async {
          try {
            debugPrint('=== Creating Employee ===');
            debugPrint('EmpId: $empId');
            debugPrint('Name: $empName');
            debugPrint('Role: ${role.roleName}');
            debugPrint('Email: $email');
            debugPrint('EmpDate: $empDate');
            
            final result = await _controller.createEmployee(
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
              password: password,
            );

            debugPrint('=== Employee Creation Result ===');
            debugPrint('Result: $result');

            return result;
          } catch (e) {
            debugPrint('=== Employee Creation Error ===');
            debugPrint('Error: $e');
            rethrow;
          }
        },
      ),
    );

    // Show snackbar after dialog is closed
    if (!mounted) return;
    
    if (result != null) {
      final createdEmpId = result['empId'];
      CustomSnackbar.showSuccess(
        context,
        'Employee created successfully (ID: $createdEmpId)',
      );
      // Refresh the employee list
      await _controller.fetchEmployees();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content (always full width)
            Column(
              children: [
                // Top bar (no action buttons)
                HrTopBar(
                  isSidebarVisible: _isSidebarVisible,
                  onToggleSidebar: () => setState(() => _isSidebarVisible = !_isSidebarVisible),
                  pageTitle: _getPageTitle(),
                ),
                // Content
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
            // Sidebar overlay
            if (_isSidebarVisible)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: HrSidebar(
                  selectedMenu: _selectedMenu,
                  onMenuSelected: (index) => setState(() => _selectedMenu = index),
                  onLogout: _logout,
                  isVisible: _isSidebarVisible,
                ),
              ),
          ],
        ),
      ),
      // Floating action button for Roles and Employees screens
      floatingActionButton: _selectedMenu == 1 || _selectedMenu == 2
          ? FloatingActionButton(
              onPressed: _selectedMenu == 1 ? _showCreateRoleDialog : _showCreateEmployeeDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildContent() {
    switch (_selectedMenu) {
      case 0:
        return const DashboardView();
      case 1:
        return const RolesView();
      case 2:
        return EmployeesView(onEmployeeTap: _showEmployeeProfile);
      case 3:
        return const ProfileView();
      default:
        return const DashboardView();
    }
  }
}
