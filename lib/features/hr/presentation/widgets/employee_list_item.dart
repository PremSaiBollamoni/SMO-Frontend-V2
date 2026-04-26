import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/employee_model.dart';

/// Employee list item widget
class EmployeeListItem extends StatefulWidget {
  final EmployeeModel employee;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onCheckboxChanged;
  final VoidCallback? onDelete;

  const EmployeeListItem({
    super.key,
    required this.employee,
    this.isSelected = false,
    this.onTap,
    this.onCheckboxChanged,
    this.onDelete,
  });

  @override
  State<EmployeeListItem> createState() => _EmployeeListItemState();
}

class _EmployeeListItemState extends State<EmployeeListItem> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(EmployeeListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _isSelected = widget.isSelected;
    }
  }

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
          value: _isSelected,
          onChanged: (value) {
            setState(() {
              _isSelected = value ?? false;
            });
            widget.onCheckboxChanged?.call();
          },
        ),
        title: Text(widget.employee.empName, style: AppTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: ${widget.employee.empId}'),
            Text('Role: ${widget.employee.role.roleName}'),
            Text('Email: ${widget.employee.email}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(
                  widget.employee.status,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.employee.status,
                style: TextStyle(
                  color: _statusColor(widget.employee.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.error, size: 20),
              onPressed: widget.onDelete,
              tooltip: 'Delete employee',
            ),
          ],
        ),
        onTap: widget.onTap,
      ),
    );
  }
}
