import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/role_model.dart';

/// Role list item widget
class RoleListItem extends StatelessWidget {
  final RoleModel role;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onCheckboxChanged;

  const RoleListItem({
    super.key,
    required this.role,
    this.isSelected = false,
    this.onTap,
    this.onCheckboxChanged,
  });

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return AppTheme.success;
      case 'INACTIVE':
        return AppTheme.warning;
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (_) => onCheckboxChanged?.call(),
        ),
        title: Text(
          role.roleName,
          style: AppTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: ${role.roleId}'),
            Text('Activity: ${role.activity}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor(role.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            role.status,
            style: TextStyle(
              color: _statusColor(role.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
