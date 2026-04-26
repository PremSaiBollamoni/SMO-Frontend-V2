import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/role_model.dart';

/// Role list item widget with proper state management for checkbox
class RoleListItem extends StatefulWidget {
  final RoleModel role;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onCheckboxChanged;
  final VoidCallback? onDelete;

  const RoleListItem({
    super.key,
    required this.role,
    this.isSelected = false,
    this.onTap,
    this.onCheckboxChanged,
    this.onDelete,
  });

  @override
  State<RoleListItem> createState() => _RoleListItemState();
}

class _RoleListItemState extends State<RoleListItem> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(RoleListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      setState(() {
        _isSelected = widget.isSelected;
      });
    }
  }

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
          value: _isSelected,
          onChanged: (value) {
            setState(() {
              _isSelected = value ?? false;
            });
            widget.onCheckboxChanged?.call();
          },
        ),
        title: Text(widget.role.roleName, style: AppTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: ${widget.role.roleId}'),
            Text('Activity: ${widget.role.activity}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(widget.role.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.role.status,
                style: TextStyle(
                  color: _statusColor(widget.role.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.error, size: 20),
              onPressed: widget.onDelete,
              tooltip: 'Delete role',
            ),
          ],
        ),
        onTap: widget.onTap,
      ),
    );
  }
}
