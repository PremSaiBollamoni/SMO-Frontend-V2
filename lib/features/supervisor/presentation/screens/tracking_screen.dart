import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/tracking_controller.dart';
import '../../../../core/theme/app_theme.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrackingController());

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Tracking',
                    style: AppTheme.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track machine, employee, and tray operations',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Divider(height: 32),

                  // Flow Status Display (shows last operation result)
                  Obx(
                    () => controller.lastResponse.value != null
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  controller.lastFlowType.value == 'ASSIGNMENT'
                                  ? Colors.blue.shade50
                                  : Colors.green.shade50,
                              border: Border.all(
                                color:
                                    controller.lastFlowType.value ==
                                        'ASSIGNMENT'
                                    ? Colors.blue
                                    : Colors.green,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  controller.lastFlowType.value == 'ASSIGNMENT'
                                      ? Icons.assignment
                                      : Icons.check_circle,
                                  color:
                                      controller.lastFlowType.value ==
                                          'ASSIGNMENT'
                                      ? Colors.blue
                                      : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Last Operation: ${controller.lastFlowType.value}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        controller
                                                .lastResponse
                                                .value!['message'] ??
                                            '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Machine QR
                  _buildQrField(
                    context,
                    label: 'Machine QR',
                    controller: controller.machineQrController,
                    onScan: () => _showQrScanner(
                      context,
                      'Scan Machine QR',
                      controller.setMachineQr,
                    ),
                    quickTestValues: [
                      'MACHINE_M001',
                      'MACHINE_M002',
                      'MACHINE_CUT001',
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Employee QR
                  _buildQrField(
                    context,
                    label: 'Employee QR',
                    controller: controller.employeeQrController,
                    onScan: () => _showQrScanner(
                      context,
                      'Scan Employee QR',
                      controller.setEmployeeQr,
                    ),
                    quickTestValues: ['EMP_1001', 'EMP_1002', 'WORKER_A001'],
                  ),
                  const SizedBox(height: 16),

                  // Tray QR
                  _buildQrField(
                    context,
                    label: 'Tray QR',
                    controller: controller.trayQrController,
                    onScan: () => _showQrScanner(
                      context,
                      'Scan Tray QR',
                      controller.setTrayQr,
                    ),
                    quickTestValues: [
                      'TRAY_001_TEST',
                      'TRAY_002_TEST',
                      'BIN_QR_12345',
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Current Operation Display
                  Obx(
                    () => controller.isLoadingBinInfo.value
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Loading bin info...'),
                              ],
                            ),
                          )
                        : controller.currentOperationName.value != null
                            ? Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Current Operation:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            controller
                                                    .currentOperationName.value ??
                                                '',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),

                  // Status Dropdown
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            children: [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: controller.selectedStatus.value,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          hint: const Text('Select Status'),
                          items: controller.statusOptions.map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              controller.selectedStatus.value = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a status';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.cancelForm,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.submitForm,
                          style: AppTheme.primaryButtonStyle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: controller.isSubmitting.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required VoidCallback onScan,
    List<String>? quickTestValues,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Scan or enter $label manually',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please scan or enter $label';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Allow manual input for testing
                  if (value.trim().isNotEmpty) {
                    controller.text = value.trim();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
        // Quick test buttons for development
        if (quickTestValues != null && quickTestValues.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              children: quickTestValues
                  .map(
                    (value) => OutlinedButton(
                      onPressed: () => controller.text = value,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text(value, style: const TextStyle(fontSize: 12)),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  void _showQrScanner(
    BuildContext context,
    String title,
    Function(String) onCodeScanned,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String? code = barcodes.first.rawValue;
                      if (code != null && code.trim().isNotEmpty) {
                        onCodeScanned(code.trim());
                        Navigator.pop(context);
                        Get.snackbar(
                          'Success',
                          'QR Code scanned successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          'Invalid QR Code detected',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
