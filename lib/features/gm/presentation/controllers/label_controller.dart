import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smo_flutter/features/gm/data/api/master_data_api_service.dart';
import 'package:smo_flutter/features/gm/data/models/label_model.dart';

class LabelController extends GetxController {
  final MasterDataApiService _apiService = MasterDataApiService();

  final labels = <LabelModel>[].obs;
  final isLoading = false.obs;

  final labelCodeController = TextEditingController();
  final labelNameController = TextEditingController();
  final labelTypeController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedStatus = 'ACTIVE'.obs;

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
    fetchLabels();
  }

  @override
  void onClose() {
    labelCodeController.dispose();
    labelNameController.dispose();
    labelTypeController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> fetchLabels() async {
    try {
      isLoading.value = true;
      final data = await _apiService.getAllLabels();
      labels.value = data;
    } catch (e) {
      showMessage('Error fetching labels: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createLabel() async {
    if (labelCodeController.text.trim().isEmpty ||
        labelNameController.text.trim().isEmpty ||
        labelTypeController.text.trim().isEmpty) {
      showMessage('Please fill all required fields', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final label = LabelModel(
        labelCode: labelCodeController.text.trim(),
        labelName: labelNameController.text.trim(),
        labelType: labelTypeController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        status: selectedStatus.value,
      );

      final response = await _apiService.createLabel(label);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Label created successfully');
        clearForm();
        fetchLabels();
      } else {
        showMessage(response['message'] ?? 'Failed to create label', isError: true);
      }
    } catch (e) {
      showMessage('Error creating label: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateLabel(int id) async {
    if (labelCodeController.text.trim().isEmpty ||
        labelNameController.text.trim().isEmpty ||
        labelTypeController.text.trim().isEmpty) {
      showMessage('Please fill all required fields', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final label = LabelModel(
        labelId: id,
        labelCode: labelCodeController.text.trim(),
        labelName: labelNameController.text.trim(),
        labelType: labelTypeController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        status: selectedStatus.value,
      );

      final response = await _apiService.updateLabel(id, label);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Label updated successfully');
        clearForm();
        fetchLabels();
      } else {
        showMessage(response['message'] ?? 'Failed to update label', isError: true);
      }
    } catch (e) {
      showMessage('Error updating label: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteLabel(int id) async {
    try {
      isLoading.value = true;
      final response = await _apiService.deleteLabel(id);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Label deleted successfully');
        fetchLabels();
      } else {
        showMessage(response['message'] ?? 'Failed to delete label', isError: true);
      }
    } catch (e) {
      showMessage('Error deleting label: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void loadLabelForEdit(LabelModel label) {
    labelCodeController.text = label.labelCode;
    labelNameController.text = label.labelName;
    labelTypeController.text = label.labelType;
    descriptionController.text = label.description ?? '';
    selectedStatus.value = label.status;
  }

  void clearForm() {
    labelCodeController.clear();
    labelNameController.clear();
    labelTypeController.clear();
    descriptionController.clear();
    selectedStatus.value = 'ACTIVE';
  }
}
