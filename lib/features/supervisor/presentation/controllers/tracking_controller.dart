import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/api/tracking_api_service.dart';
import '../../domain/models/tracking_model.dart';

class TrackingController extends GetxController {
  final TrackingApiService _apiService = TrackingApiService();
  final formKey = GlobalKey<FormState>();

  // Form fields
  final machineQrController = TextEditingController();
  final employeeQrController = TextEditingController();
  final trayQrController = TextEditingController();

  // Status dropdown
  var selectedStatus = Rx<String?>(null);
  final List<String> statusOptions = ['Completed', 'Pending'];

  // Loading states
  var isSubmitting = false.obs;

  // Flow type tracking
  var lastFlowType = ''.obs;
  var lastResponse = Rx<Map<String, dynamic>?>(null);

  @override
  void onClose() {
    machineQrController.dispose();
    employeeQrController.dispose();
    trayQrController.dispose();
    super.onClose();
  }

  // Set Machine QR from scanner
  void setMachineQr(String code) {
    if (code.trim().isNotEmpty) {
      machineQrController.text = code.trim();
    }
  }

  // Set Employee QR from scanner
  void setEmployeeQr(String code) {
    if (code.trim().isNotEmpty) {
      employeeQrController.text = code.trim();
    }
  }

  // Set Tray QR from scanner
  void setTrayQr(String code) {
    if (code.trim().isNotEmpty) {
      trayQrController.text = code.trim();
    }
  }

  // Validate form
  bool validateForm() {
    if (formKey.currentState?.validate() != true) {
      return false;
    }

    if (machineQrController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please scan Machine QR',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (employeeQrController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please scan Employee QR',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (trayQrController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please scan Tray QR',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (selectedStatus.value == null || selectedStatus.value!.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // Submit form with enhanced two-phase workflow
  Future<void> submitForm() async {
    if (!validateForm()) return;

    try {
      isSubmitting.value = true;

      final tracking = TrackingModel(
        machineQr: machineQrController.text.trim(),
        employeeQr: employeeQrController.text.trim(),
        trayQr: trayQrController.text.trim(),
        status: selectedStatus.value!,
        supervisorId: 1004, // Default supervisor ID
      );

      final result = await _apiService.submitTracking(tracking);

      if (result['success'] == true) {
        final responseData = result['data'] as Map<String, dynamic>;
        lastResponse.value = responseData;
        lastFlowType.value = responseData['flowType'] ?? '';

        // Show success message with flow type information
        String message =
            responseData['message'] ?? 'Tracking submitted successfully';
        String flowType = responseData['flowType'] ?? '';

        Color backgroundColor = Colors.green;
        String title = 'Success';

        if (flowType == 'ASSIGNMENT') {
          backgroundColor = Colors.blue;
          title = 'Assignment Created';
        } else if (flowType == 'COMPLETION') {
          backgroundColor = Colors.green;
          title = 'Job Completed';
        }

        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: backgroundColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        resetForm();
      } else {
        throw Exception(result['message'] ?? 'Submission failed');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit tracking: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // Reset form
  void resetForm() {
    formKey.currentState?.reset();
    machineQrController.clear();
    employeeQrController.clear();
    trayQrController.clear();
    selectedStatus.value = null;
  }

  // Cancel form
  void cancelForm() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Tracking'),
        content: const Text(
          'Are you sure you want to cancel? All data will be lost.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('No')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              resetForm();
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
