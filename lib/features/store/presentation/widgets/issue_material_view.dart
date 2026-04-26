import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/store_controller.dart';

/// Issue Material View
class IssueMaterialView extends StatefulWidget {
  const IssueMaterialView({super.key});

  @override
  State<IssueMaterialView> createState() => _IssueMaterialViewState();
}

class _IssueMaterialViewState extends State<IssueMaterialView> {
  final _itemIdController = TextEditingController();
  final _qtyController = TextEditingController();
  final _locationController = TextEditingController(text: 'MAIN');
  final _bundleIdController = TextEditingController();

  @override
  void dispose() {
    _itemIdController.dispose();
    _qtyController.dispose();
    _locationController.dispose();
    _bundleIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = Get.find<StoreController>();
    final itemId = int.tryParse(_itemIdController.text.trim());
    final qty = int.tryParse(_qtyController.text.trim());
    final location = _locationController.text.trim();
    final bundleIdText = _bundleIdController.text.trim();
    final bundleId = bundleIdText.isEmpty ? null : int.tryParse(bundleIdText);

    if (itemId == null || qty == null || qty <= 0) {
      CustomSnackbar.showError(context, 'itemId and positive qty are required');
      return;
    }

    if (bundleIdText.isNotEmpty && bundleId == null) {
      CustomSnackbar.showError(context, 'bundleId must be numeric');
      return;
    }

    try {
      final result = await controller.issueMaterial(
        itemId: itemId,
        qty: qty,
        location: location.isEmpty ? 'MAIN' : location,
        bundleId: bundleId,
      );
      if (!mounted) return;
      final remain = result['remainingQty']?.toString() ?? '-';
      CustomSnackbar.showSuccess(
        context,
        'Material issued. Remaining Qty: $remain',
      );
      _itemIdController.clear();
      _qtyController.clear();
      _bundleIdController.clear();
    } catch (e) {
      if (!mounted) return;
      String msg = 'Failed to issue material';
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
                Text('Issue Material', style: AppTheme.headlineMedium),
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
                      ? AppTheme.darkInputDecoration('Issue Qty *')
                      : AppTheme.inputDecoration('Issue Qty *'),
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
                  controller: _bundleIdController,
                  keyboardType: TextInputType.number,
                  decoration: dark
                      ? AppTheme.darkInputDecoration('Bundle ID (optional)')
                      : AppTheme.inputDecoration('Bundle ID (optional)'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _submit,
                    style: AppTheme.secondaryButtonStyle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(
                              color: AppTheme.onPrimary,
                            )
                          : Text(
                              'ISSUE MATERIAL',
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
