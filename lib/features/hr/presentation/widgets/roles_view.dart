import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/hr_controller.dart';
import 'role_list_item.dart';

/// Roles management view widget
class RolesView extends StatelessWidget {
  const RolesView({super.key});

  Future<void> _deleteRole(
    BuildContext context,
    HrController controller,
    int roleId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: const Text('Are you sure you want to delete this role?'),
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
      final success = await controller.deleteRole(roleId);
      if (context.mounted) {
        if (success) {
          CustomSnackbar.showSuccess(context, 'Role deleted');
        } else {
          CustomSnackbar.showError(
            context,
            'Failed to delete role. Backend delete endpoint may not be implemented yet.',
          );
        }
      }
    }
  }

  Future<void> _deleteBulkRoles(
    BuildContext context,
    HrController controller,
  ) async {
    final selectedIds = controller.selectedRoleIds
        .map((id) => int.tryParse(id))
        .whereType<int>()
        .toList();

    if (selectedIds.isEmpty) {
      CustomSnackbar.showError(context, 'Select roles to delete');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Roles'),
        content: Text('Delete ${selectedIds.length} role(s)?'),
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
      final success = await controller.deleteRoles(selectedIds);
      if (context.mounted) {
        if (success) {
          CustomSnackbar.showSuccess(
            context,
            '${selectedIds.length} role(s) deleted',
          );
        } else {
          CustomSnackbar.showError(
            context,
            'Failed to delete roles. Backend delete endpoint may not be implemented yet.',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HrController>();

    return Obx(() {
      final filteredRoles = controller.filteredRoles;
      final selectedCount = controller.selectedRoleIds.length;

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
                        controller.roleSearchQuery.value = value,
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
                    onPressed: () => controller.clearRoleSelections(),
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _deleteBulkRoles(context, controller),
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
          // Role list
          Expanded(
            child: filteredRoles.isEmpty
                ? const Center(child: Text('No roles found'))
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 80,
                    ),
                    itemCount: filteredRoles.length,
                    itemBuilder: (context, index) {
                      final role = filteredRoles[index];
                      return RoleListItem(
                        role: role,
                        isSelected: controller.selectedRoleIds.contains(
                          role.roleId.toString(),
                        ),
                        onCheckboxChanged: () => controller.toggleRoleSelection(
                          role.roleId.toString(),
                        ),
                        onDelete: () =>
                            _deleteRole(context, controller, role.roleId),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}
