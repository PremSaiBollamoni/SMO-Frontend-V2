import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/qr_assignment_controller.dart';
import '../widgets/tray_quantity_stepper.dart';
import '../../../../core/theme/app_theme.dart';

class QrAssignmentScreen extends StatelessWidget {
  const QrAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QrAssignmentController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
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
                    'QR Code Assignment',
                    style: AppTheme.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Assign QR codes to production items',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Divider(height: 32),

                  // Process Plan Number
                  _buildDropdownField(
                    label: 'Process Plan Number',
                    value: controller.selectedProcessPlan.value,
                    items: controller.processPlanNumbers,
                    onChanged: (value) {
                      controller.selectedProcessPlan.value = value;
                      if (value != null) {
                        controller.loadOperations(value);
                      }
                    },
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  // Order Number (Optional)
                  Obx(() {
                    if (controller.activeOrders.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    return Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: controller.selectedOrderNumber.value,
                          decoration: const InputDecoration(
                            labelText: 'Order Number (Optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.assignment),
                            hintText: 'Select order to link bin',
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('No Order (Unassigned)'),
                            ),
                            ...controller.activeOrders.map((order) {
                              return DropdownMenuItem<String>(
                                value: order['order_number'] ?? order['order_id']?.toString(),
                                child: Text('${order['order_number'] ?? order['order_id']} - Product #${order['product_id']}'),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            controller.selectedOrderNumber.value = value;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),

                  // QR Code Field with Scan Button
                  _buildQrCodeField(context, controller),
                  const SizedBox(height: 16),

                  // Style
                  _buildDropdownField(
                    label: 'Style',
                    value: controller.selectedStyle.value,
                    items: controller.styles,
                    onChanged: (value) =>
                        controller.selectedStyle.value = value,
                  ),
                  const SizedBox(height: 16),

                  // Size
                  _buildDropdownField(
                    label: 'Size',
                    value: controller.selectedSize.value,
                    items: controller.sizes,
                    onChanged: (value) => controller.selectedSize.value = value,
                  ),
                  const SizedBox(height: 16),

                  // GTG Number
                  _buildDropdownField(
                    label: 'GTG Number',
                    value: controller.selectedGtg.value,
                    items: controller.gtgNumbers,
                    onChanged: (value) => controller.selectedGtg.value = value,
                  ),
                  const SizedBox(height: 16),

                  // Button Number (BTN)
                  _buildDropdownField(
                    label: 'Button Number (BTN)',
                    value: controller.selectedBtn.value,
                    items: controller.btnNumbers,
                    onChanged: (value) => controller.selectedBtn.value = value,
                  ),
                  const SizedBox(height: 16),

                  // Label
                  _buildDropdownField(
                    label: 'Label',
                    value: controller.selectedLabel.value,
                    items: controller.labels,
                    onChanged: (value) =>
                        controller.selectedLabel.value = value,
                  ),
                  const SizedBox(height: 16),

                  // Next Operation (Dropdown from routing operations)
                  Obx(() {
                    if (controller.operations.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    return Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: controller.selectedNextOperation.value,
                          decoration: const InputDecoration(
                            labelText: 'Next Operation',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.settings),
                            hintText: 'Select next operation',
                          ),
                          items: controller.operations.map((op) {
                            return DropdownMenuItem<String>(
                              value: op['name']?.toString(),
                              child: Text('${op['name']} (Seq: ${op['sequence']})'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            controller.selectedNextOperation.value = value;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),

                  // Tray Quantity
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tray Quantity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TrayQuantityStepper(
                        value: controller.trayQuantity.value,
                        onIncrement: controller.incrementTrayQuantity,
                        onDecrement: controller.decrementTrayQuantity,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Optional Notes Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.note_add, color: Colors.grey.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Additional Notes (Optional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: controller.notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText:
                                'Enter any additional notes about this assignment...',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
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
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
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
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: Text('Select $label'),
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select $label';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildQrCodeField(
    BuildContext context,
    QrAssignmentController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'QR Code',
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
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.qrCodeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Scan or enter QR Code manually',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please scan or enter a QR code';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Allow manual input for testing
                  if (value.trim().isNotEmpty) {
                    controller.qrCodeController.text = value.trim();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showQrScanner(context, controller),
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
        const SizedBox(height: 8),
        // Quick test buttons for development
        if (true) // Set to false in production
          Wrap(
            spacing: 8,
            children: [
              _buildQuickTestButton('TRAY_001_TEST', controller),
              _buildQuickTestButton('TRAY_002_TEST', controller),
              _buildQuickTestButton('BIN_QR_12345', controller),
            ],
          ),
      ],
    );
  }

  Widget _buildQuickTestButton(
    String qrCode,
    QrAssignmentController controller,
  ) {
    return OutlinedButton(
      onPressed: () => controller.setQrCode(qrCode),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 32),
      ),
      child: Text(qrCode, style: const TextStyle(fontSize: 12)),
    );
  }

  void _showQrScanner(BuildContext context, QrAssignmentController controller) {
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
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        controller.setQrCode(code.trim());
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
