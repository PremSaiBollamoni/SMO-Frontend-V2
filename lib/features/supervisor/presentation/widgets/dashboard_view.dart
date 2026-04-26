import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/supervisor_controller.dart';

/// Dashboard View - Monitor WIP and floor insights
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupervisorController>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final insights = controller.floorInsights.value;
      final loading = controller.loadingInsights.value;

      return RefreshIndicator(
        onRefresh: () => controller.fetchFloorInsights(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCard(
              dark,
              Row(
                children: [
                  Expanded(
                    child: Text('Monitor WIP', style: AppTheme.headlineMedium),
                  ),
                  IconButton(
                    onPressed: loading
                        ? null
                        : () => controller.fetchFloorInsights(),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (insights == null)
              _buildCard(
                dark,
                Text('No data. Pull to refresh.', style: AppTheme.bodyLarge),
              )
            else ...[
              _buildCard(
                dark,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WIP Overview', style: AppTheme.titleLarge),
                    const SizedBox(height: 12),
                    _buildMetricRow(
                      'Active WIP Count',
                      '${insights.activeWipCount}',
                      AppTheme.primary,
                    ),
                    _buildMetricRow(
                      'Bottleneck Operations',
                      '${insights.bottleneckOperationCount}',
                      insights.bottleneckOperationCount > 0
                          ? AppTheme.error
                          : AppTheme.success,
                    ),
                  ],
                ),
              ),
              _buildCard(
                dark,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Line Balancing', style: AppTheme.titleLarge),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          insights.isBalanced
                              ? Icons.check_circle_outline
                              : Icons.warning_amber_outlined,
                          color: insights.isBalanced
                              ? AppTheme.success
                              : AppTheme.warning,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insights.lineBalancingHint,
                            style: AppTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildCard(
                dark,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Insights', style: AppTheme.titleLarge),
                    const SizedBox(height: 10),
                    Text(insights.aiInsight, style: AppTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ],
        ),
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
