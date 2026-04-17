import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/hr_controller.dart';
import 'employee_list_item.dart';

/// Employees management view widget
class EmployeesView extends StatelessWidget {
  final Function(String) onEmployeeTap;

  const EmployeesView({
    super.key,
    required this.onEmployeeTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HrController>();

    return Obx(() {
      final filteredEmployees = controller.filteredEmployees;
      final roles = controller.roles;

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
          // Employee list
          Expanded(
            child: filteredEmployees.isEmpty
                ? const Center(child: Text('No employees found'))
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = filteredEmployees[index];
                      return EmployeeListItem(
                        employee: employee,
                        isSelected: controller.selectedEmployeeIds
                            .contains(employee.empId),
                        onTap: () => onEmployeeTap(employee.empId),
                        onCheckboxChanged: () =>
                            controller.toggleEmployeeSelection(employee.empId),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}
