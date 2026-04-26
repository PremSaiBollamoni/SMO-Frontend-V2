import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/store_controller.dart';

/// Manage Inventory View - Create/update inventory
class ManageInventoryView extends StatefulWidget {
  const ManageInventoryView({super.key});

  @override
  State<ManageInventoryView> createState() => _ManageInventoryViewState();
}

class _ManageInventoryViewState extends State<ManageInventoryView> {
  final _itemIdController = TextEditingController();
  final _qtyController = TextEditingController();
  final _locationController = TextEditingController(text: 'MAIN');
  final _batchController = TextEditingController();

  @override
  void dispose() {
    _itemIdController.dispose();
    _qtyController.dispose();
    _locationController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = Get.find<StoreController>();
    final itemId = int.tryParse(_itemIdController.text.trim());
    final qty = int.tryParse(_qtyController.text.trim());
    final location = _locationController.text.trim();
    final batch = _batchController.text.trim();

    if (itemId == null || qty == null) {
      CustomSnackbar.showError(
        context,
        'itemId and qty are required and must be numbers',
      );
      return;
    }

    try {
      await controller.upsertInventory(
        itemId: itemId,
        qty: qty,
        location: location.isEmpty ? 'MAIN' : location,
        batch: batch.isEmpty ? null : batch,
      );
      if (!mounted) return;
      CustomSnackbar.showSuccess(context, 'Inventory updated');
      _itemIdController.clear();
      _qtyController.clear();
      _batchController.clear();
    } catch (e) {
      if (!mounted) return;
      String msg = 'Failed to update inventory';
      if (e is DioException) {
        msg = e.response?.data?['message']?.toString() ?? e.message ?? msg;
      }
      CustomSnackbar.showError(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoreController>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: dark
                ? AppTheme.darkCardDecoration
                : AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manage Inventory', style: AppTheme.headlineMedium),
                const SizedBox(height: 10),
                Text(
                  'Create/update stock using live backend API. No hardcoded values.',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _itemIdController,
                  keyboardType: TextInputType.number,
                  decoration: dark
                      ? AppTheme.darkInputDecoration('Item ID *')
                      : AppTheme.inputDecoration('Item ID *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: dark
                      ? AppTheme.darkInputDecoration('Quantity *')
                      : AppTheme.inputDecoration('Quantity *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _locationController,
                  decoration: dark
                      ? AppTheme.darkInputDecoration('Location (default MAIN)')
                      : AppTheme.inputDecoration('Location (default MAIN)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _batchController,
                  decoration: dark
                      ? AppTheme.darkInputDecoration('Batch (optional)')
                      : AppTheme.inputDecoration('Batch (optional)'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _submit,
                    style: AppTheme.primaryButtonStyle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(
                              color: AppTheme.onPrimary,
                            )
                          : Text(
                              'SAVE INVENTORY',
                              style: AppTheme.labelLarge.copyWith(
                                color: AppTheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
