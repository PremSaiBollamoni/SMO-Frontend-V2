import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/merging_controller.dart';
import '../../../../core/theme/app_theme.dart';

class MergingScreen extends StatelessWidget {
  const MergingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MergingController());

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
                    'Merging',
                    style: AppTheme.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Merge two tubs into one',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Divider(height: 32),

                  // Tub 1 Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.inbox, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Tub 1',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildQrField(
                          context,
                          label: 'Tub 1 QR',
                          controller: controller.tub1QrController,
                          onScan: () => _showQrScanner(
                            context,
                            'Scan Tub 1 QR',
                            controller.setTub1Qr,
                          ),
                          quickTestValues: [
                            'TRAY_001_TEST',
                            'BIN_QR_12345',
                            'CONTAINER_001',
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Tub Description',
                          controller: controller.tub1DescriptionController,
                          hint: 'Enter tub 1 description',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tub 2 Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.inbox, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Tub 2',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildQrField(
                          context,
                          label: 'Tub 2 QR',
                          controller: controller.tub2QrController,
                          onScan: () => _showQrScanner(
                            context,
                            'Scan Tub 2 QR',
                            controller.setTub2Qr,
                          ),
                          quickTestValues: [
                            'TRAY_002_TEST',
                            'BIN_QR_67890',
                            'CONTAINER_002',
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Tub Description',
                          controller: controller.tub2DescriptionController,
                          hint: 'Enter tub 2 description',
                        ),
                      ],
                    ),
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
                                'Enter any additional notes about this merge...',
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
                                : const Text('Merge'),
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
                  filled: true,
                  fillColor: Colors.white,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
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
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
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
