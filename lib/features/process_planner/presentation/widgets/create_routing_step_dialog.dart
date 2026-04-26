import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/process_planner_controller.dart';

/// Dialog for creating a new routing step
class CreateRoutingStepDialog extends StatefulWidget {
  final Future<bool> Function({
    required int routingStepId,
    required int routingId,
    required int operationId,
    required int stageGroup,
  })
  onCreateRoutingStep;

  const CreateRoutingStepDialog({super.key, required this.onCreateRoutingStep});

  @override
  State<CreateRoutingStepDialog> createState() =>
      _CreateRoutingStepDialogState();
}

class _CreateRoutingStepDialogState extends State<CreateRoutingStepDialog> {
  final _formKey = GlobalKey<FormState>();
  final _stageGroupController = TextEditingController(text: '1');
  String? _selectedRoutingId;
  String? _selectedOperationId;
  bool _isCreating = false;

  @override
  void dispose() {
    _stageGroupController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRoutingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a routing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedOperationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an operation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final routingStepId = DateTime.now().millisecondsSinceEpoch ~/ 10000;
      final success = await widget.onCreateRoutingStep(
        routingStepId: routingStepId,
        routingId: int.parse(_selectedRoutingId!),
        operationId: int.parse(_selectedOperationId!),
        stageGroup: int.tryParse(_stageGroupController.text.trim()) ?? 1,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create routing step'),
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
    final controller = Get.find<ProcessPlannerController>();

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
                    'Create Routing Step',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: _selectedRoutingId,
                      decoration: dark
                          ? AppTheme.darkInputDecoration('Select Routing *')
                          : AppTheme.inputDecoration('Select Routing *'),
                      items: controller.routings.map((routing) {
                        return DropdownMenuItem<String>(
                          value: routing.routingId.toString(),
                          child: Text('Routing #${routing.routingId}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedRoutingId = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a routing';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: _selectedOperationId,
                      decoration: dark
                          ? AppTheme.darkInputDecoration('Select Operation *')
                          : AppTheme.inputDecoration('Select Operation *'),
                      items: controller.operations.map((operation) {
                        return DropdownMenuItem<String>(
                          value: operation.operationId.toString(),
                          child: Text(operation.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedOperationId = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an operation';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stageGroupController,
                    decoration: dark
                        ? AppTheme.darkInputDecoration('Stage Group')
                        : AppTheme.inputDecoration('Stage Group'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Stage group is required';
                      }
                      return null;
                    },
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
