import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smo_flutter/features/gm/data/api/master_data_api_service.dart';
import 'package:smo_flutter/features/gm/data/models/button_model.dart';

class ButtonController extends GetxController {
  final MasterDataApiService _apiService = MasterDataApiService();

  final buttons = <ButtonModel>[].obs;
  final isLoading = false.obs;

  final buttonCodeController = TextEditingController();
  final buttonNameController = TextEditingController();
  final selectedStatus = 'ACTIVE'.obs;

  // Store BuildContext for showing snackbars
  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  void showMessage(String message, {bool isError = false}) {
    if (_context != null && _context!.mounted) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchButtons();
  }

  @override
  void onClose() {
    buttonCodeController.dispose();
    buttonNameController.dispose();
    super.onClose();
  }

  Future<void> fetchButtons() async {
    try {
      isLoading.value = true;
      final data = await _apiService.getAllButtons();
      buttons.value = data;
    } catch (e) {
      showMessage('Error fetching buttons: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createButton() async {
    if (buttonCodeController.text.trim().isEmpty ||
        buttonNameController.text.trim().isEmpty) {
      showMessage('Please fill all required fields', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final button = ButtonModel(
        buttonCode: buttonCodeController.text.trim(),
        buttonName: buttonNameController.text.trim(),
        status: selectedStatus.value,
      );

      final response = await _apiService.createButton(button);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Button created successfully');
        clearForm();
        fetchButtons();
        // Dialog will be closed by caller
      } else {
        showMessage(response['message'] ?? 'Failed to create button', isError: true);
      }
    } catch (e) {
      showMessage('Error creating button: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateButton(int id) async {
    if (buttonCodeController.text.trim().isEmpty ||
        buttonNameController.text.trim().isEmpty) {
      showMessage('Please fill all required fields', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final button = ButtonModel(
        buttonId: id,
        buttonCode: buttonCodeController.text.trim(),
        buttonName: buttonNameController.text.trim(),
        status: selectedStatus.value,
      );

      final response = await _apiService.updateButton(id, button);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Button updated successfully');
        clearForm();
        fetchButtons();
        // Dialog will be closed by caller
      } else {
        showMessage(response['message'] ?? 'Failed to update button', isError: true);
      }
    } catch (e) {
      showMessage('Error updating button: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteButton(int id) async {
    try {
      isLoading.value = true;
      final response = await _apiService.deleteButton(id);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Button deleted successfully');
        fetchButtons();
      } else {
        showMessage(response['message'] ?? 'Failed to delete button', isError: true);
      }
    } catch (e) {
      showMessage('Error deleting button: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void loadButtonForEdit(ButtonModel button) {
    buttonCodeController.text = button.buttonCode;
    buttonNameController.text = button.buttonName;
    selectedStatus.value = button.status;
  }

  void clearForm() {
    buttonCodeController.clear();
    buttonNameController.clear();
    selectedStatus.value = 'ACTIVE';
  }
}
