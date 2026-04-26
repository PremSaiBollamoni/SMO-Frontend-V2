import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/store_controller.dart';

/// Stock Movements View
class StockMovementsView extends StatelessWidget {
  const StockMovementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoreController>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      return RefreshIndicator(
        onRefresh: controller.fetchMovements,
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
                    child: Text(
                      'Stock Movements',
                      style: AppTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: controller.loadingMovements.value
                        ? null
                        : controller.fetchMovements,
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (controller.loadingMovements.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (controller.stockMovements.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: dark
                    ? AppTheme.darkCardDecoration
                    : AppTheme.cardDecoration,
                child: Text(
                  'No stock movements found.',
                  style: AppTheme.bodyLarge,
                ),
              )
            else
              ...controller.stockMovements.map(
                (m) => Padding(
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
                          'Movement #${m.movementId ?? '-'}',
                          style: AppTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Item ID: ${m.itemId ?? '-'}'),
                        Text('Type: ${m.type ?? '-'}'),
                        Text('Qty: ${m.qty ?? '-'}'),
                        Text('Timestamp: ${m.timestamp ?? '-'}'),
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
