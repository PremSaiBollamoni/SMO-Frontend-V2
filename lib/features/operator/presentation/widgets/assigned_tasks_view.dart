import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/operator_controller.dart';

/// Assigned Tasks View - List of assigned tasks
class AssignedTasksView extends StatelessWidget {
  const AssignedTasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OperatorController>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      return RefreshIndicator(
        onRefresh: controller.fetchTasks,
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
                      'Assigned Tasks',
                      style: AppTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: controller.loadingTasks.value
                        ? null
                        : controller.fetchTasks,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (controller.loadingTasks.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (controller.tasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: dark
                    ? AppTheme.darkCardDecoration
                    : AppTheme.cardDecoration,
                child: Text(
                  'No active assigned tasks.',
                  style: AppTheme.bodyLarge,
                ),
              )
            else
              ...controller.tasks.map(
                (task) => Padding(
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
                          'WIP #${task.wipId ?? '-'}',
                          style: AppTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Bundle: ${task.bundleId ?? '-'}'),
                        Text('Operation: ${task.operationId ?? '-'}'),
                        Text('Machine: ${task.machineId ?? '-'}'),
                        Text('Qty: ${task.qty ?? '-'}'),
                        Text('Started: ${task.startTime ?? '-'}'),
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
