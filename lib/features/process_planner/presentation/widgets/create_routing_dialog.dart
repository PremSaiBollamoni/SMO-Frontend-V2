import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/process_planner_controller.dart';

/// Dialog for creating a new routing
class CreateRoutingDialog extends StatefulWidget {
  final Future<bool> Function({
    required int routingId,
    required int productId,
    required int version,
    required String status,
    required String approvalStatus,
  })
  onCreateRouting;

  const CreateRoutingDialog({super.key, required this.onCreateRouting});

  @override
  State<CreateRoutingDialog> createState() => _CreateRoutingDialogState();
}

class _CreateRoutingDialogState extends State<CreateRoutingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _versionController = TextEditingController(text: '1');
  String? _selectedProductId;
  bool _isCreating = false;

  @override
  void dispose() {
    _versionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final routingId = DateTime.now().millisecondsSinceEpoch ~/ 10000;
      final success = await widget.onCreateRouting(
        routingId: routingId,
        productId: int.parse(_selectedProductId!),
        version: int.tryParse(_versionController.text.trim()) ?? 1,
        status: 'ACTIVE',
        approvalStatus: 'PENDING',
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create routing'),
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
                    'Create Routing',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value: _selectedProductId,
                      decoration: dark
                          ? AppTheme.darkInputDecoration('Select Product *')
                          : AppTheme.inputDecoration('Select Product *'),
                      items: controller.products.map((product) {
                        return DropdownMenuItem<String>(
                          value: product.productId.toString(),
                          child: Text(product.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedProductId = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a product';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _versionController,
                    decoration: dark
                        ? AppTheme.darkInputDecoration('Version')
                        : AppTheme.inputDecoration('Version'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Version is required';
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
