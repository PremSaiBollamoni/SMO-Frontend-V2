import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/process_planner_controller.dart';

/// Products View - List and manage products
class ProductsView extends StatelessWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProcessPlannerController>();

    return Obx(() {
      if (controller.isLoading.value && controller.products.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchProducts(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(context, controller),
            const SizedBox(height: 16),
            if (controller.products.isEmpty)
              _buildEmptyState()
            else
              ...controller.products.map(
                (product) => _buildProductCard(context, product),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(
    BuildContext context,
    ProcessPlannerController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkCardDecoration
          : AppTheme.cardDecoration,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Products (${controller.products.length})',
              style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: controller.isLoading.value
                ? null
                : () => controller.fetchProducts(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration,
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No products yet',
              style: AppTheme.bodyLarge.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first product',
              style: AppTheme.bodySmall.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, dynamic product) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: dark ? AppTheme.darkCardDecoration : AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: AppTheme.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildStatusChip(product.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${product.productId} • Category: ${product.category}',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = status.toUpperCase() == 'ACTIVE' ? Colors.green : Colors.grey;
    return Chip(
      label: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
