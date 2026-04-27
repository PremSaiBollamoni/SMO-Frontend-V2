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
  final notesController = TextEditingController();

  // Dropdown values
  var selectedProcessPlan = Rx<String?>(null);
  var selectedStyle = Rx<String?>(null);
  var selectedSize = Rx<String?>(null);
  var selectedGtg = Rx<String?>(null);
  var selectedBtn = Rx<String?>(null);
  var selectedLabel = Rx<String?>(null);
  var selectedOrderNumber = Rx<String?>(null); // Added for order linkage
  var selectedNextOperation = Rx<String?>(null); // Changed from text field to dropdown

  // Tray quantity
  var trayQuantity = 1.obs;

  // Dropdown options
  var processPlanNumbers = <String>[].obs;
  var styles = <String>[].obs;
  var sizes = <String>[].obs;
  var gtgNumbers = <String>[].obs;
  var btnNumbers = <String>[].obs;
  var labels = <String>[].obs;
  var activeOrders = <Map<String, dynamic>>[].obs; // Added for order selection
  var operations = <Map<String, dynamic>>[].obs; // Added for next operation dropdown

  // Loading states
  var isLoading = false.obs;
  var isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDropdownData();
    loadActiveOrders();
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

  // Load active orders
  Future<void> loadActiveOrders() async {
    try {
      final orders = await _apiService.getActiveOrders();
      activeOrders.value = orders;
    } catch (e) {
      debugPrint('[QR_ASSIGNMENT] Failed to load active orders: $e');
    }
  }

  // Load operations for selected process plan
  Future<void> loadOperations(String routingId) async {
    try {
      operations.clear();
      selectedNextOperation.value = null;
      
      final ops = await _apiService.getOperationsForRouting(routingId);
      operations.value = ops;
    } catch (e) {
      debugPrint('[QR_ASSIGNMENT] Failed to load operations: $e');
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
        nextOperation: selectedNextOperation.value?.trim() ?? '',
        trayQuantity: trayQuantity.value,
        supervisorId: 1004,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        orderNumber: selectedOrderNumber.value, // Include order number
      );

      final response = await _apiService.submitQrAssignment(assignment);

      if (response['success'] == true) {
        String message =
            response['message'] ?? 'QR Assignment submitted successfully';
        if (response['binId'] != null) {
          message += '\nBin ID: ${response['binId']}';
        }
        if (selectedOrderNumber.value != null) {
          message += '\nLinked to Order: ${selectedOrderNumber.value}';
        }

        // Use WidgetsBinding to ensure context is available
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.context != null) {
            Get.snackbar(
              'Success',
              message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
          }
        });
        resetForm();
      } else {
        String errorType = response['errorType'] ?? 'UNKNOWN_ERROR';
        String message = response['message'] ?? 'Assignment failed';

        Color backgroundColor = Colors.red;

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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.context != null) {
            Get.snackbar(
              'Assignment Failed',
              message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: backgroundColor,
              colorText: Colors.white,
              duration: const Duration(seconds: 5),
            );
          }
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          Get.snackbar(
            'Error',
            'Failed to submit QR assignment: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }
      });
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
    selectedOrderNumber.value = null;
    selectedNextOperation.value = null;
    trayQuantity.value = 1;
    operations.clear();
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
