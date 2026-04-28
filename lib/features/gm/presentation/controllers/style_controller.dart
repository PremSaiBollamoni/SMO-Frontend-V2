import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smo_flutter/features/gm/data/api/master_data_api_service.dart';
import 'package:smo_flutter/features/gm/data/models/style_model.dart';

class StyleController extends GetxController {
  final MasterDataApiService _apiService = MasterDataApiService();

  final styles = <StyleModel>[].obs;
  final isLoading = false.obs;

  final styleNoController = TextEditingController();
  final conceptController = TextEditingController();
  final mainLabelController = TextEditingController();
  final brandingLabelController = TextEditingController();
  final patternImageController = TextEditingController();
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
    fetchStyles();
  }

  @override
  void onClose() {
    styleNoController.dispose();
    conceptController.dispose();
    mainLabelController.dispose();
    brandingLabelController.dispose();
    patternImageController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> fetchStyles() async {
    try {
      isLoading.value = true;
      final data = await _apiService.getAllStyles();
      styles.value = data;
    } catch (e) {
      showMessage('Error fetching styles: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createStyle() async {
    if (styleNoController.text.trim().isEmpty) {
      showMessage('Style No is required', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final style = StyleModel(
        styleNo: styleNoController.text.trim(),
        concept: conceptController.text.trim().isEmpty ? null : conceptController.text.trim(),
        mainLabel: mainLabelController.text.trim().isEmpty ? null : mainLabelController.text.trim(),
        brandingLabel: brandingLabelController.text.trim().isEmpty ? null : brandingLabelController.text.trim(),
        patternImage: patternImageController.text.trim().isEmpty ? null : patternImageController.text.trim(),
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
        status: selectedStatus.value,
      );

      final response = await _apiService.createStyle(style);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Style created successfully');
        clearForm();
        fetchStyles();
      } else {
        showMessage(response['message'] ?? 'Failed to create style', isError: true);
      }
    } catch (e) {
      showMessage('Error creating style: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStyle(int id) async {
    if (styleNoController.text.trim().isEmpty) {
      showMessage('Style No is required', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final style = StyleModel(
        styleId: id,
        styleNo: styleNoController.text.trim(),
        concept: conceptController.text.trim().isEmpty ? null : conceptController.text.trim(),
        mainLabel: mainLabelController.text.trim().isEmpty ? null : mainLabelController.text.trim(),
        brandingLabel: brandingLabelController.text.trim().isEmpty ? null : brandingLabelController.text.trim(),
        patternImage: patternImageController.text.trim().isEmpty ? null : patternImageController.text.trim(),
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
        status: selectedStatus.value,
      );

      final response = await _apiService.updateStyle(id, style);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Style updated successfully');
        clearForm();
        fetchStyles();
      } else {
        showMessage(response['message'] ?? 'Failed to update style', isError: true);
      }
    } catch (e) {
      showMessage('Error updating style: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStyle(int id) async {
    try {
      isLoading.value = true;
      final response = await _apiService.deleteStyle(id);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Style deleted successfully');
        fetchStyles();
      } else {
        showMessage(response['message'] ?? 'Failed to delete style', isError: true);
      }
    } catch (e) {
      showMessage('Error deleting style: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void loadStyleForEdit(StyleModel style) {
    styleNoController.text = style.styleNo;
    conceptController.text = style.concept ?? '';
    mainLabelController.text = style.mainLabel ?? '';
    brandingLabelController.text = style.brandingLabel ?? '';
    patternImageController.text = style.patternImage ?? '';
    descriptionController.text = style.description ?? '';
    selectedStatus.value = style.status;
  }

  void clearForm() {
    styleNoController.clear();
    conceptController.clear();
    mainLabelController.clear();
    brandingLabelController.clear();
    patternImageController.clear();
    descriptionController.clear();
    selectedStatus.value = 'ACTIVE';
  }
}
