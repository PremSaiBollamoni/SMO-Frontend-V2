import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/store_controller.dart';

/// Stock Levels View
class StockLevelsView extends StatelessWidget {
  const StockLevelsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoreController>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      return RefreshIndicator(
        onRefresh: controller.fetchStockLevels,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: dark
                  ? AppTheme.darkCardDecoration
                  : AppTheme.cardDecoration,
              child: Row(
                children: [
                  Expanded(
                    child: Text('Stock Levels', style: AppTheme.headlineMedium),
                  ),
                  IconButton(
                    onPressed: controller.loadingStockLevels.value
                        ? null
                        : controller.fetchStockLevels,
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (controller.loadingStockLevels.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (controller.stockLevels.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: dark
                    ? AppTheme.darkCardDecoration
                    : AppTheme.cardDecoration,
                child: Text('No data found.', style: AppTheme.bodyLarge),
              )
            else
              ...controller.stockLevels.map(
                (item) => Padding(
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
                          'Stock #${item.stockId ?? '-'}',
                          style: AppTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Item ID: ${item.itemId ?? '-'}'),
                        Text('Qty: ${item.qty ?? '-'}'),
                        Text('Location: ${item.location ?? '-'}'),
                        Text('Batch: ${item.batch ?? '-'}'),
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
