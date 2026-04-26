import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/hr_controller.dart';
import 'employee_list_item.dart';

/// Employees management view widget
class EmployeesView extends StatelessWidget {
  final Function(String) onEmployeeTap;

  const EmployeesView({super.key, required this.onEmployeeTap});

  Future<void> _deleteEmployee(
    BuildContext context,
    HrController controller,
    String empId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to delete this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await controller.deleteEmployee(empId);
      if (context.mounted) {
        if (success) {
          CustomSnackbar.showSuccess(context, 'Employee deleted');
        } else {
          CustomSnackbar.showError(
            context,
            'Failed to delete employee. Backend delete endpoint may not be implemented yet.',
          );
        }
      }
    }
  }

  Future<void> _deleteBulkEmployees(
    BuildContext context,
    HrController controller,
  ) async {
    final selectedIds = controller.selectedEmployeeIds.toList();
    if (selectedIds.isEmpty) {
      CustomSnackbar.showError(context, 'Select employees to delete');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employees'),
        content: Text('Delete ${selectedIds.length} employee(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await controller.deleteEmployees(selectedIds);
      if (context.mounted) {
        if (success) {
          CustomSnackbar.showSuccess(
            context,
            '${selectedIds.length} employee(s) deleted',
          );
        } else {
          CustomSnackbar.showError(
            context,
            'Failed to delete employees. Backend delete endpoint may not be implemented yet.',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HrController>();

    return Obx(() {
      final filteredEmployees = controller.filteredEmployees;
      final roles = controller.roles;
      final selectedCount = controller.selectedEmployeeIds.length;

      return Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) =>
                        controller.employeeSearchQuery.value = value,
                    decoration: AppTheme.inputDecoration('Search employees...'),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: controller.employeeRoleFilter.value,
                  items: [
                    const DropdownMenuItem(value: 'ALL', child: Text('ALL')),
                    ...roles.map(
                      (r) => DropdownMenuItem(
                        value: r.roleName,
                        child: Text(
                          r.roleName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.employeeRoleFilter.value = value;
                    }
                  },
                ),
              ],
            ),
          ),
          // Bulk delete bar
          if (selectedCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Text(
                    '$selectedCount selected',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => controller.clearEmployeeSelections(),
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _deleteBulkEmployees(context, controller),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          // Employee list
          Expanded(
            child: filteredEmployees.isEmpty
                ? const Center(child: Text('No employees found'))
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 80,
                    ),
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = filteredEmployees[index];
                      return EmployeeListItem(
                        employee: employee,
                        isSelected: controller.selectedEmployeeIds.contains(
                          employee.empId,
                        ),
                        onTap: () => onEmployeeTap(employee.empId),
                        onCheckboxChanged: () =>
                            controller.toggleEmployeeSelection(employee.empId),
                        onDelete: () => _deleteEmployee(
                          context,
                          controller,
                          employee.empId,
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}
