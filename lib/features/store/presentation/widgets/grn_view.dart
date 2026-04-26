import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/store_controller.dart';

/// GRN View - Goods Receipt Note
class GrnView extends StatefulWidget {
  const GrnView({super.key});

  @override
  State<GrnView> createState() => _GrnViewState();
}

class _GrnViewState extends State<GrnView> {
  final _poIdController = TextEditingController();

  @override
  void dispose() {
    _poIdController.dispose();
    super.dispose();
  }

  Future<void> _createGrn() async {
    final controller = Get.find<StoreController>();
    final poIdText = _poIdController.text.trim();
    final poId = poIdText.isEmpty ? null : int.tryParse(poIdText);

    try {
      await controller.createGrn(poId: poId);
      if (!mounted) return;
      CustomSnackbar.showSuccess(context, 'GRN created');
      _poIdController.clear();
    } catch (e) {
      if (!mounted) return;
      String msg = 'Failed to create GRN';
      if (e is DioException) {
        msg = e.response?.data?['message']?.toString() ?? e.message ?? msg;
      }
      CustomSnackbar.showError(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoreController>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      return RefreshIndicator(
        onRefresh: controller.fetchGrns,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: dark
                  ? AppTheme.darkCardDecoration
                  : AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Receive Goods (GRN)', style: AppTheme.headlineMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Create a Goods Receipt Note when goods arrive.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _poIdController,
                    keyboardType: TextInputType.number,
                    decoration: dark
                        ? AppTheme.darkInputDecoration(
                            'Purchase Order ID (optional)',
                          )
                        : AppTheme.inputDecoration(
                            'Purchase Order ID (optional)',
                          ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : _createGrn,
                      style: AppTheme.secondaryButtonStyle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: AppTheme.onPrimary,
                              )
                            : Text(
                                'CREATE GRN',
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: dark
                  ? AppTheme.darkCardDecoration
                  : AppTheme.cardDecoration,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'GRN Records (${controller.grns.length})',
                      style: AppTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: controller.loadingGrns.value
                        ? null
                        : controller.fetchGrns,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (controller.loadingGrns.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (controller.grns.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: dark
                    ? AppTheme.darkCardDecoration
                    : AppTheme.cardDecoration,
                child: Text('No GRN records yet.', style: AppTheme.bodyLarge),
              )
            else
              ...controller.grns.map(
                (g) => Padding(
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
                          'GRN #${g.grnId ?? '-'}',
                          style: AppTheme.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'PO ID: ${g.poId ?? '-'} • Date: ${g.date ?? '-'} • ${g.status ?? '-'}',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
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
