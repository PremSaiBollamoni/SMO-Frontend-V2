import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/supervisor_controller.dart';

/// Reassign Work View - Merge bins to reassign work
class ReassignWorkView extends StatelessWidget {
  const ReassignWorkView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SupervisorController>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final merging = controller.mergingBins.value;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            dark,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reassign Work', style: AppTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  'Merge source bundle into target bundle to reassign work.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.targetBundleController,
                  keyboardType: TextInputType.number,
                  decoration: dark
                      ? AppTheme.darkInputDecoration('Target Bundle ID *')
                      : AppTheme.inputDecoration('Target Bundle ID *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.sourceBundleController,
                  keyboardType: TextInputType.number,
                  decoration: dark
                      ? AppTheme.darkInputDecoration('Source Bundle ID *')
                      : AppTheme.inputDecoration('Source Bundle ID *'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: merging ? null : () => _handleMergeBins(context),
                    style: AppTheme.primaryButtonStyle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: merging
                          ? const CircularProgressIndicator(
                              color: AppTheme.onPrimary,
                            )
                          : Text(
                              'REASSIGN / MERGE BINS',
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

  Future<void> _handleMergeBins(BuildContext context) async {
    final controller = Get.find<SupervisorController>();

    try {
      final message = await controller.mergeBins();
      if (context.mounted) {
        _showSuccess(context, message);
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, _extractDioError(e));
      }
    }
  }

  String _extractDioError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        return data['message']?.toString() ??
            data['error']?.toString() ??
            'API Error';
      }
      if (data is String && data.isNotEmpty) return data;
      return e.message ?? 'Unknown network error';
    }
    return e.toString();
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.success),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.error),
    );
  }
}
