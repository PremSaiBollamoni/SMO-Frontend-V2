import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/supervisor_controller.dart';

/// Operator Performance View - Monitor operator metrics
class OperatorPerformanceView extends StatelessWidget {
  const OperatorPerformanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupervisorController>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final insights = controller.floorInsights.value;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            dark,
            Text('Operator Performance', style: AppTheme.headlineMedium),
          ),
          _buildCard(
            dark,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WIP Summary', style: AppTheme.titleLarge),
                const SizedBox(height: 10),
                if (insights != null) ...[
                  _buildMetricRow(
                    'Active WIP',
                    '${insights.activeWipCount}',
                    AppTheme.primary,
                  ),
                  _buildMetricRow(
                    'Bottleneck Ops',
                    '${insights.bottleneckOperationCount}',
                    AppTheme.warning,
                  ),
                ] else
                  Text(
                    'Load dashboard first to see WIP data.',
                    style: AppTheme.bodyMedium,
                  ),
              ],
            ),
          ),
          _buildCard(
            dark,
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Per-operator drill-down requires operator ID. Use Reassign Work to rebalance.',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.onSurfaceVariant,
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

  Widget _buildCard(bool dark, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: dark ? AppTheme.darkCardDecoration : AppTheme.cardDecoration,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              value,
              style: AppTheme.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
