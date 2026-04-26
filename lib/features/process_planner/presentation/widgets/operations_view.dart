import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/process_planner_controller.dart';

/// Operations View - List and manage operations
class OperationsView extends StatelessWidget {
  const OperationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProcessPlannerController>();

    return Obx(() {
      if (controller.isLoading.value && controller.operations.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchOperations(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(context, controller),
            const SizedBox(height: 16),
            if (controller.operations.isEmpty)
              _buildEmptyState()
            else
              ...controller.operations.map(
                (operation) => _buildOperationCard(context, operation),
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
              'Operations (${controller.operations.length})',
              style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: controller.isLoading.value
                ? null
                : () => controller.fetchOperations(),
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
              Icons.settings_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No operations yet',
              style: AppTheme.bodyLarge.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first operation',
              style: AppTheme.bodySmall.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationCard(BuildContext context, dynamic operation) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: dark ? AppTheme.darkCardDecoration : AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            operation.name,
            style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'ID: ${operation.operationId} • Seq: ${operation.sequence} • Std Time: ${operation.standardTime} min',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          if (operation.isParallel || operation.mergePoint) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (operation.isParallel)
                  Chip(
                    label: Text(
                      'Parallel',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                if (operation.mergePoint)
                  Chip(
                    label: Text(
                      'Merge Point',
                      style: TextStyle(
                        color: AppTheme.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: AppTheme.secondary.withValues(alpha: 0.1),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
