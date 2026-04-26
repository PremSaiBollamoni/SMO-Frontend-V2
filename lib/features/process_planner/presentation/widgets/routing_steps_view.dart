import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/process_planner_controller.dart';

/// Routing Steps View - List and manage routing steps
class RoutingStepsView extends StatefulWidget {
  const RoutingStepsView({super.key});

  @override
  State<RoutingStepsView> createState() => _RoutingStepsViewState();
}

class _RoutingStepsViewState extends State<RoutingStepsView> {
  int? _selectedRoutingId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProcessPlannerController>();

    return Obx(() {
      return Column(
        children: [
          // Routing selector
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkCardDecoration
                : AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Routing',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _selectedRoutingId,
                  decoration: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkInputDecoration('Select Routing')
                      : AppTheme.inputDecoration('Select Routing'),
                  items: controller.routings.map((routing) {
                    return DropdownMenuItem<int>(
                      value: routing.routingId,
                      child: Text(
                        'Routing #${routing.routingId} (Product: ${routing.productId})',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedRoutingId = value);
                    if (value != null) {
                      controller.fetchRoutingSteps(value);
                    }
                  },
                ),
              ],
            ),
          ),
          // Steps list
          Expanded(
            child: _selectedRoutingId == null
                ? _buildSelectRoutingPrompt()
                : controller.isLoading.value && controller.routingSteps.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () =>
                        controller.fetchRoutingSteps(_selectedRoutingId!),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildHeader(context, controller),
                        const SizedBox(height: 16),
                        if (controller.routingSteps.isEmpty)
                          _buildEmptyState()
                        else
                          ...controller.routingSteps.map(
                            (step) => _buildStepCard(context, step),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildSelectRoutingPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_upward, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Select a routing to view its steps',
            style: AppTheme.bodyLarge.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
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
              'Routing Steps (${controller.routingSteps.length})',
              style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: controller.isLoading.value || _selectedRoutingId == null
                ? null
                : () => controller.fetchRoutingSteps(_selectedRoutingId!),
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
              Icons.list_alt_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No routing steps yet',
              style: AppTheme.bodyLarge.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add steps to this routing',
              style: AppTheme.bodySmall.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, dynamic step) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: dark ? AppTheme.darkCardDecoration : AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step #${step.routingStepId}',
            style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Operation ID: ${step.operationId} • Stage Group: ${step.stageGroup}',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
