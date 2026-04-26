import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/store_controller.dart';

/// Items View - Create and list items
class ItemsView extends StatefulWidget {
  const ItemsView({super.key});

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _unitController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _createItem() async {
    final controller = Get.find<StoreController>();
    if (_nameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Item name is required');
      return;
    }

    try {
      await controller.createItem(
        name: _nameController.text.trim(),
        type: _typeController.text.trim().isEmpty
            ? null
            : _typeController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        unit: _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
      );
      if (!mounted) return;
      CustomSnackbar.showSuccess(context, 'Item created');
      _nameController.clear();
      _typeController.clear();
      _categoryController.clear();
      _unitController.clear();
    } catch (e) {
      if (!mounted) return;
      String msg = 'Failed to create item';
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
      return RefreshIndicator(
        onRefresh: controller.fetchItems,
        child: ListView(
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
                  Text('Create Item', style: AppTheme.headlineMedium),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nameController,
                    decoration: dark
                        ? AppTheme.darkInputDecoration('Item Name *')
                        : AppTheme.inputDecoration('Item Name *'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _typeController,
                    decoration: dark
                        ? AppTheme.darkInputDecoration('Type')
                        : AppTheme.inputDecoration('Type'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _categoryController,
                    decoration: dark
                        ? AppTheme.darkInputDecoration('Category')
                        : AppTheme.inputDecoration('Category'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _unitController,
                    decoration: dark
                        ? AppTheme.darkInputDecoration(
                            'Unit (e.g. meters, pcs)',
                          )
                        : AppTheme.inputDecoration('Unit (e.g. meters, pcs)'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : _createItem,
                      style: AppTheme.primaryButtonStyle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: AppTheme.onPrimary,
                              )
                            : Text(
                                'CREATE ITEM',
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: dark
                  ? AppTheme.darkCardDecoration
                  : AppTheme.cardDecoration,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Items (${controller.items.length})',
                      style: AppTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: controller.loadingItems.value
                        ? null
                        : controller.fetchItems,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (controller.loadingItems.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (controller.items.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: dark
                    ? AppTheme.darkCardDecoration
                    : AppTheme.cardDecoration,
                child: Text('No items yet.', style: AppTheme.bodyLarge),
              )
            else
              ...controller.items.map(
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: dark
                        ? AppTheme.darkCardDecoration
                        : AppTheme.cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i.name ?? '-'}',
                          style: AppTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'ID: ${i.itemId} • Type: ${i.type ?? '-'} • Unit: ${i.unit ?? '-'} • ${i.status ?? '-'}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
