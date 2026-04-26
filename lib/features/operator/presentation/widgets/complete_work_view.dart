import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/operator_controller.dart';
import 'qr_scanner_page.dart';

/// Complete Work View - Form to complete work
class CompleteWorkView extends StatefulWidget {
  const CompleteWorkView({super.key});

  @override
  State<CompleteWorkView> createState() => _CompleteWorkViewState();
}

class _CompleteWorkViewState extends State<CompleteWorkView> {
  final _trayQrController = TextEditingController();
  final _bundleIdController = TextEditingController();
  final _operationIdController = TextEditingController();
  final _machineIdController = TextEditingController();
  final _qtyController = TextEditingController();

  @override
  void dispose() {
    _trayQrController.dispose();
    _bundleIdController.dispose();
    _operationIdController.dispose();
    _machineIdController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _scan(TextEditingController ctrl, String title) async {
    final raw = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => QrScannerPage(title: title)),
    );
    if (!mounted || raw == null || raw.trim().isEmpty) return;
    setState(() => ctrl.text = _parseQr(raw.trim()));
  }

  /// Parse QR payload smartly
  String _parseQr(String raw) {
    // 1. JSON
    try {
      final d = jsonDecode(raw);
      if (d is Map) {
        for (final k in const [
          'bundleId',
          'machineId',
          'operationId',
          'trayQr',
          'id',
          'value',
          'code',
        ]) {
          final v = d[k];
          if (v != null && v.toString().trim().isNotEmpty) {
            return v.toString().trim();
          }
        }
      }
    } catch (_) {}

    // 2. key=value or key:value
    final kv = RegExp(
      r'(bundleId|machineId|operationId|trayQr|id|value|code)\s*[:=]\s*([A-Za-z0-9\-_]+)',
      caseSensitive: false,
    ).firstMatch(raw);
    if (kv != null) return kv.group(2)!.trim();

    // 3. first number
    final n = RegExp(r'\d+').firstMatch(raw);
    if (n != null) return n.group(0)!;

    // 4. raw
    return raw;
  }

  Future<void> _completeWork() async {
    final controller = Get.find<OperatorController>();

    final bundleId = int.tryParse(_bundleIdController.text.trim());
    final operationId = int.tryParse(_operationIdController.text.trim());
    final machineId = int.tryParse(_machineIdController.text.trim());
    final qty = int.tryParse(_qtyController.text.trim());

    if (bundleId == null || operationId == null || machineId == null) {
      CustomSnackbar.showError(
        context,
        'Bundle ID, Operation ID and Machine ID are required',
      );
      return;
    }

    try {
      await controller.completeWork(
        trayQr: _trayQrController.text.trim().isEmpty
            ? null
            : _trayQrController.text.trim(),
        bundleId: bundleId,
        operationId: operationId,
        machineId: machineId,
        qty: qty,
      );
      if (!mounted) return;
      CustomSnackbar.showSuccess(context, 'Work completed successfully');

      // Clear form
      _trayQrController.clear();
      _bundleIdController.clear();
      _operationIdController.clear();
      _machineIdController.clear();
      _qtyController.clear();
    } catch (e) {
      if (!mounted) return;
      String msg = 'Failed to complete work';
      if (e is DioException) {
        msg = e.response?.data?['message']?.toString() ?? e.message ?? msg;
      }
      CustomSnackbar.showError(context, msg);
    }
  }

  Widget _qrField({
    required TextEditingController ctrl,
    required String label,
    required String scanTitle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final controller = Get.find<OperatorController>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            decoration: dark
                ? AppTheme.darkInputDecoration(label)
                : AppTheme.inputDecoration(label),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: controller.isLoading.value
                ? null
                : () => _scan(ctrl, scanTitle),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OperatorController>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      return ListView(
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
                Text('Complete Work', style: AppTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  'Scan each QR or type the ID manually.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _qrField(
                  ctrl: _trayQrController,
                  label: 'Tray QR (optional)',
                  scanTitle: 'Scan Tray QR',
                ),
                const SizedBox(height: 12),
                _qrField(
                  ctrl: _bundleIdController,
                  label: 'Bundle ID *',
                  scanTitle: 'Scan Bundle QR',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _qrField(
                  ctrl: _operationIdController,
                  label: 'Operation ID *',
                  scanTitle: 'Scan Operation QR',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _qrField(
                  ctrl: _machineIdController,
                  label: 'Machine ID *',
                  scanTitle: 'Scan Machine QR',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: dark
                      ? AppTheme.darkInputDecoration('Quantity (optional)')
                      : AppTheme.inputDecoration('Quantity (optional)'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : _completeWork,
                    style: AppTheme.secondaryButtonStyle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(
                              color: AppTheme.onPrimary,
                            )
                          : Text(
                              'COMPLETE WORK',
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
}
