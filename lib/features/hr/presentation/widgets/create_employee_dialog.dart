import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/role_model.dart';

/// Create employee dialog widget
class CreateEmployeeDialog extends StatefulWidget {
  final List<RoleModel> roles;
  final Function({
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
  }) onCreateEmployee;

  const CreateEmployeeDialog({
    super.key,
    required this.roles,
    required this.onCreateEmployee,
  });

  @override
  State<CreateEmployeeDialog> createState() => _CreateEmployeeDialogState();
}

class _CreateEmployeeDialogState extends State<CreateEmployeeDialog> {
  final _empIdController = TextEditingController();
  final _empNameController = TextEditingController();
  String? _newEmployeeRoleId;
  final _empDobController = TextEditingController();
  final _empPhoneController = TextEditingController();
  final _empAddressController = TextEditingController();
  final _empEmailController = TextEditingController();
  final _empSalaryController = TextEditingController();
  final _empDateController = TextEditingController();
  final _empBloodGroupController = TextEditingController();
  final _empEmergencyController = TextEditingController();
  final _empAadharController = TextEditingController();
  final _empPanCardController = TextEditingController();
  final _empPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.roles.isNotEmpty) {
      _newEmployeeRoleId = widget.roles.first.roleId.toString();
    }
  }

  @override
  void dispose() {
    _empIdController.dispose();
    _empNameController.dispose();
    _empDobController.dispose();
    _empPhoneController.dispose();
    _empAddressController.dispose();
    _empEmailController.dispose();
    _empSalaryController.dispose();
    _empDateController.dispose();
    _empBloodGroupController.dispose();
    _empEmergencyController.dispose();
    _empAadharController.dispose();
    _empPanCardController.dispose();
    _empPasswordController.dispose();
    super.dispose();
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkInputDecoration(label)
            : AppTheme.inputDecoration(label),
      ),
    );
  }

  void _handleCreate() async {
    // Validate role selection first
    if (_newEmployeeRoleId == null) {
      CustomSnackbar.showError(context, 'Please select a role');
      return;
    }

    final selectedRole = widget.roles.firstWhere(
      (r) => r.roleId.toString() == _newEmployeeRoleId,
    );
    final empId = int.tryParse(_empIdController.text.trim());

    // Detailed validation with specific error messages
    if (empId == null) {
      CustomSnackbar.showError(
        context,
        'Employee ID is required and must be numeric',
      );
      return;
    }
    if (_empNameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Employee Name is required');
      return;
    }
    if (_empEmailController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Email is required');
      return;
    }
    if (_empDateController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Joining Date is required');
      return;
    }
    if (_empPasswordController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Password is required');
      return;
    }

    final salary = _empSalaryController.text.trim().isEmpty
        ? null
        : double.tryParse(_empSalaryController.text.trim());

    try {
      final result = await widget.onCreateEmployee(
        empId: empId.toString(),
        empName: _empNameController.text.trim(),
        role: selectedRole,
        dob: _empDobController.text.trim().isEmpty
            ? null
            : _empDobController.text.trim(),
        phone: _empPhoneController.text.trim().isEmpty
            ? null
            : _empPhoneController.text.trim(),
        address: _empAddressController.text.trim().isEmpty
            ? null
            : _empAddressController.text.trim(),
        email: _empEmailController.text.trim(),
        salary: salary,
        empDate: _empDateController.text.trim(),
        bloodGroup: _empBloodGroupController.text.trim().isEmpty
            ? null
            : _empBloodGroupController.text.trim(),
        emergencyContact: _empEmergencyController.text.trim().isEmpty
            ? null
            : _empEmergencyController.text.trim(),
        aadharNumber: _empAadharController.text.trim().isEmpty
            ? null
            : _empAadharController.text.trim(),
        panCardNumber: _empPanCardController.text.trim().isEmpty
            ? null
            : _empPanCardController.text.trim(),
        password: _empPasswordController.text.trim(),
      );
      
      // Close dialog and return result
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      // Show error in dialog context
      if (mounted) {
        CustomSnackbar.showError(context, 'Failed: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.roles.isEmpty) {
      return AlertDialog(
        title: const Text('Error'),
        content: const Text('Create at least one role first'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_add_alt_1, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Text('Create Employee', style: AppTheme.titleLarge),
                ],
              ),
            ),
            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field(_empIdController, 'Employee ID'),
                    _field(_empNameController, 'Employee Name'),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DropdownButtonFormField<String>(
                        value: _newEmployeeRoleId,
                        isExpanded: true,
                        items: widget.roles
                            .map(
                              (r) => DropdownMenuItem<String>(
                                value: r.roleId.toString(),
                                child: Text(
                                  '${r.roleName} (${r.roleId})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _newEmployeeRoleId = value;
                          });
                        },
                        decoration: Theme.of(context).brightness ==
                                Brightness.dark
                            ? AppTheme.darkInputDecoration('Role')
                            : AppTheme.inputDecoration('Role'),
                      ),
                    ),
                    _field(_empDobController, 'DOB (YYYY-MM-DD)'),
                    _field(_empPhoneController, 'Phone'),
                    _field(_empAddressController, 'Address'),
                    _field(_empEmailController, 'Email'),
                    _field(_empSalaryController, 'Salary'),
                    _field(_empDateController, 'Joining Date (YYYY-MM-DD)'),
                    _field(_empBloodGroupController, 'Blood Group'),
                    _field(_empEmergencyController, 'Emergency Contact'),
                    _field(_empAadharController, 'Aadhar Number'),
                    _field(_empPanCardController, 'PAN Card Number'),
                    _field(_empPasswordController, 'Password'),
                  ],
                ),
              ),
            ),
            // Footer buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _handleCreate,
                    icon: const Icon(Icons.check),
                    label: const Text('Create'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
