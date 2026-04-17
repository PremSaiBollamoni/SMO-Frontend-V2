import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/hr_controller.dart';
import 'role_list_item.dart';

/// Roles management view widget
class RolesView extends StatelessWidget {
  const RolesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HrController>();

    return Obx(() {
      final filteredRoles = controller.filteredRoles;

      return Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => controller.roleSearchQuery.value = value,
                    decoration: AppTheme.inputDecoration('Search roles...'),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: controller.roleStatusFilter.value,
                  items: ['ALL', 'ACTIVE', 'INACTIVE']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.roleStatusFilter.value = value;
                    }
                  },
                ),
              ],
            ),
          ),
          // Role list
          Expanded(
            child: filteredRoles.isEmpty
                ? const Center(child: Text('No roles found'))
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                    itemCount: filteredRoles.length,
                    itemBuilder: (context, index) {
                      final role = filteredRoles[index];
                      return RoleListItem(
                        role: role,
                        isSelected: controller.selectedRoleIds
                            .contains(role.roleId.toString()),
                        onCheckboxChanged: () =>
                            controller.toggleRoleSelection(role.roleId.toString()),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}
