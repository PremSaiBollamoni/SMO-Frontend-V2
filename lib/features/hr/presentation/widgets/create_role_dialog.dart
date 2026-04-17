import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Create role dialog widget
class CreateRoleDialog extends StatefulWidget {
  final Function({
    required int roleId,
    required String roleName,
    required String activity,
    required String status,
  }) onCreateRole;

  const CreateRoleDialog({
    super.key,
    required this.onCreateRole,
  });

  @override
  State<CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends State<CreateRoleDialog> {
  static const List<String> _roleStatuses = ['ACTIVE', 'INACTIVE'];

  final _roleIdController = TextEditingController();
  final _roleNameController = TextEditingController();
  final _roleActivityController = TextEditingController();
  String _newRoleStatus = 'ACTIVE';

  @override
  void dispose() {
    _roleIdController.dispose();
    _roleNameController.dispose();
    _roleActivityController.dispose();
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

  void _handleCreate() {
    final roleIdStr = _roleIdController.text.trim();
    final roleId = int.tryParse(roleIdStr);
    
    if (roleId == null || _roleNameController.text.trim().isEmpty) {
      CustomSnackbar.showError(
        context,
        'Valid Numeric Role ID and Role Name are required',
      );
      return;
    }

    Navigator.of(context).pop();
    widget.onCreateRole(
      roleId: roleId,
      roleName: _roleNameController.text.trim(),
      activity: _roleActivityController.text.trim(),
      status: _newRoleStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Role'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_roleIdController, 'Role ID'),
            _field(_roleNameController, 'Role Name'),
            _field(_roleActivityController, 'Activity'),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DropdownButtonFormField<String>(
                value: _newRoleStatus,
                items: _roleStatuses
                    .map(
                      (status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _newRoleStatus = value);
                },
                decoration: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkInputDecoration('Status')
                    : AppTheme.inputDecoration('Status'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleCreate,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
