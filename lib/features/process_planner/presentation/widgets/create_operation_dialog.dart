import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// Dialog for creating a new operation
class CreateOperationDialog extends StatefulWidget {
  final Future<bool> Function({
    required int operationId,
    required String name,
    required String description,
    required int sequence,
    required int standardTime,
    required bool isParallel,
    required bool mergePoint,
    required int stageGroup,
  })
  onCreateOperation;

  const CreateOperationDialog({super.key, required this.onCreateOperation});

  @override
  State<CreateOperationDialog> createState() => _CreateOperationDialogState();
}

class _CreateOperationDialogState extends State<CreateOperationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController(text: 'Manual Entry');
  final _sequenceController = TextEditingController(text: '0');
  final _standardTimeController = TextEditingController(text: '0');
  bool _isParallel = false;
  bool _isMergePoint = false;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sequenceController.dispose();
    _standardTimeController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final operationId = DateTime.now().millisecondsSinceEpoch ~/ 10000;
      final success = await widget.onCreateOperation(
        operationId: operationId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        sequence: int.tryParse(_sequenceController.text.trim()) ?? 0,
        standardTime: int.tryParse(_standardTimeController.text.trim()) ?? 0,
        isParallel: _isParallel,
        mergePoint: _isMergePoint,
        stageGroup: 1,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create operation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Operation',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: dark
                        ? AppTheme.darkInputDecoration('Operation Name *')
                        : AppTheme.inputDecoration('Operation Name *'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Operation name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: dark
                        ? AppTheme.darkInputDecoration('Description')
                        : AppTheme.inputDecoration('Description'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _sequenceController,
                    decoration: dark
                        ? AppTheme.darkInputDecoration('Sequence')
                        : AppTheme.inputDecoration('Sequence'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _standardTimeController,
                    decoration: dark
                        ? AppTheme.darkInputDecoration('Standard Time (mins)')
                        : AppTheme.inputDecoration('Standard Time (mins)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Parallel Operation',
                      style: AppTheme.bodyMedium,
                    ),
                    value: _isParallel,
                    onChanged: (v) => setState(() => _isParallel = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Merge Point', style: AppTheme.bodyMedium),
                    value: _isMergePoint,
                    onChanged: (v) => setState(() => _isMergePoint = v),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isCreating
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isCreating ? null : _handleCreate,
                        style: AppTheme.primaryButtonStyle,
                        child: _isCreating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
