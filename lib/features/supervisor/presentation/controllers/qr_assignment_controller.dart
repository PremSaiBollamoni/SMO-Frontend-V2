import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/api/qr_assignment_api_service.dart';
import '../../domain/models/qr_assignment_model.dart';

class QrAssignmentController extends GetxController {
  final QrAssignmentApiService _apiService = QrAssignmentApiService();
  final formKey = GlobalKey<FormState>();

  // Form fields
  final qrCodeController = TextEditingController();
  final nextOperationController = TextEditingController();
  final notesController =
      TextEditingController(); // Added for enhanced workflow

  // Dropdown values
  var selectedProcessPlan = Rx<String?>(null);
  var selectedStyle = Rx<String?>(null);
  var selectedSize = Rx<String?>(null);
  var selectedGtg = Rx<String?>(null);
  var selectedBtn = Rx<String?>(null);
  var selectedLabel = Rx<String?>(null);

  // Tray quantity
  var trayQuantity = 1.obs;

  // Dropdown options
  var processPlanNumbers = <String>[].obs;
  var styles = <String>[].obs;
  var sizes = <String>[].obs;
  var gtgNumbers = <String>[].obs;
  var btnNumbers = <String>[].obs;
  var labels = <String>[].obs;

  // Loading states
  var isLoading = false.obs;
  var isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDropdownData();
  }

  @override
  void onClose() {
    qrCodeController.dispose();
    nextOperationController.dispose();
    notesController.dispose();
    super.onClose();
  }

  // Load all dropdown data
  Future<void> loadDropdownData() async {
    try {
      isLoading.value = true;

      // Load all dropdown data in parallel
      final results = await Future.wait([
        _apiService.getProcessPlanNumbers(),
        _apiService.getStyles(),
        _apiService.getSizes(),
        _apiService.getGtgNumbers(),
        _apiService.getBtnNumbers(),
        _apiService.getLabels(),
      ]);

      processPlanNumbers.value = results[0];
      styles.value = results[1];
      sizes.value = results[2];
      gtgNumbers.value = results[3];
      btnNumbers.value = results[4];
      labels.value = results[5];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dropdown data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Increment tray quantity
  void incrementTrayQuantity() {
    trayQuantity.value++;
  }

  // Decrement tray quantity
  void decrementTrayQuantity() {
    if (trayQuantity.value > 1) {
      trayQuantity.value--;
    }
  }

  // Set QR code from scanner
  void setQrCode(String code) {
    if (code.trim().isNotEmpty) {
      qrCodeController.text = code.trim();
    }
  }

  // Validate form
  bool validateForm() {
    if (formKey.currentState?.validate() != true) {
      return false;
    }

    if (selectedProcessPlan.value == null ||
        selectedProcessPlan.value!.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a Process Plan Number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (qrCodeController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please scan or enter a QR Code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (trayQuantity.value <= 0) {
      Get.snackbar(
        'Validation Error',
        'Tray quantity must be greater than 0',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // Submit form
  Future<void> submitForm() async {
    if (!validateForm()) return;

    try {
      isSubmitting.value = true;

      final assignment = QrAssignmentModel(
        processPlanNumber: selectedProcessPlan.value!,
        qrCode: qrCodeController.text.trim(),
        style: selectedStyle.value?.trim() ?? '',
        size: selectedSize.value?.trim() ?? '',
        gtgNumber: selectedGtg.value?.trim() ?? '',
        btnNumber: selectedBtn.value?.trim() ?? '',
        label: selectedLabel.value?.trim() ?? '',
        nextOperation: nextOperationController.text.trim(),
        trayQuantity: trayQuantity.value,
        supervisorId: 1004, // Default supervisor ID
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      final response = await _apiService.submitQrAssignment(assignment);

      if (response['success'] == true) {
        // Enhanced success message with details
        String message =
            response['message'] ?? 'QR Assignment submitted successfully';
        if (response['binId'] != null) {
          message += '\nBin ID: ${response['binId']}';
        }
        if (response['assignmentStartTime'] != null) {
          message += '\nAssignment Start Time recorded';
        }

        Get.snackbar(
          'Success',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        resetForm();
      } else {
        // Enhanced error handling based on error type
        String errorType = response['errorType'] ?? 'UNKNOWN_ERROR';
        String message = response['message'] ?? 'Assignment failed';

        Color backgroundColor = Colors.red;

        // Different colors for different error types
        switch (errorType) {
          case 'VALIDATION_ERROR':
            backgroundColor = Colors.orange;
            break;
          case 'STATUS_ERROR':
            backgroundColor = Colors.amber;
            message += '\nTip: Complete current assignment before reassigning';
            break;
          case 'SYSTEM_ERROR':
            backgroundColor = Colors.red.shade700;
            break;
          case 'NETWORK_ERROR':
            backgroundColor = Colors.purple;
            break;
        }

        Get.snackbar(
          'Assignment Failed',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: backgroundColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit QR assignment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // Reset form
  void resetForm() {
    formKey.currentState?.reset();
    qrCodeController.clear();
    nextOperationController.clear();
    notesController.clear();
    selectedProcessPlan.value = null;
    selectedStyle.value = null;
    selectedSize.value = null;
    selectedGtg.value = null;
    selectedBtn.value = null;
    selectedLabel.value = null;
    trayQuantity.value = 1;
  }

  // Cancel form
  void cancelForm() {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel QR Assignment'),
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
