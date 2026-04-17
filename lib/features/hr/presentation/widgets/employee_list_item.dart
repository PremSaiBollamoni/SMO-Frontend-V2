import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/employee_model.dart';

/// Employee list item widget
class EmployeeListItem extends StatelessWidget {
  final EmployeeModel employee;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onCheckboxChanged;

  const EmployeeListItem({
    super.key,
    required this.employee,
    this.isSelected = false,
    this.onTap,
    this.onCheckboxChanged,
  });

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return AppTheme.success;
      case 'RESIGNED':
        return AppTheme.warning;
      case 'TERMINATED':
        return AppTheme.error;
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
          employee.empName,
          style: AppTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: ${employee.empId}'),
            Text('Role: ${employee.role.roleName}'),
            Text('Email: ${employee.email}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _statusColor(employee.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            employee.status,
            style: TextStyle(
              color: _statusColor(employee.status),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
