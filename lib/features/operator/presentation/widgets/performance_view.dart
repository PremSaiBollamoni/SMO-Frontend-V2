import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/operator_controller.dart';

/// Performance View - Operator performance metrics
class PerformanceView extends StatelessWidget {
  const PerformanceView({super.key});

  Widget _metric(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkSurfaceVariant
            : AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.displaySmall.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: AppTheme.bodySmall),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OperatorController>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      return RefreshIndicator(
        onRefresh: controller.fetchPerformance,
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
                      'Personal Performance',
                      style: AppTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: controller.loadingPerformance.value
                        ? null
                        : controller.fetchPerformance,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (controller.loadingPerformance.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (controller.performance.value == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: dark
                    ? AppTheme.darkCardDecoration
                    : AppTheme.cardDecoration,
                child: Text('No performance data.', style: AppTheme.bodyLarge),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: dark
                    ? AppTheme.darkCardDecoration
                    : AppTheme.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operator ID: ${controller.performance.value!.operatorId ?? controller.empId.value}',
                      style: AppTheme.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _metric(
                            context,
                            'Active Tasks',
                            '${controller.performance.value!.activeTasks ?? 0}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _metric(
                            context,
                            'Completed',
                            '${controller.performance.value!.completedTasks ?? 0}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}
