import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smo_flutter/features/gm/data/api/master_data_api_service.dart';
import 'package:smo_flutter/features/gm/data/models/gtg_model.dart';
import 'package:smo_flutter/features/gm/data/models/style_model.dart';
import 'package:smo_flutter/features/gm/data/models/button_model.dart';
import 'package:smo_flutter/features/gm/data/models/thread_model.dart';

class GtgController extends GetxController {
  final MasterDataApiService _apiService = MasterDataApiService();

  final gtgs = <GtgModel>[].obs;
  final styles = <StyleModel>[].obs;
  final buttons = <ButtonModel>[].obs;
  final threads = <ThreadModel>[].obs;
  final isLoading = false.obs;

  final gtgNoController = TextEditingController();
  final sizeController = TextEditingController();
  final sleeveTypeController = TextEditingController();
  final colorController = TextEditingController();
  final consumptionController = TextEditingController();
  final targetController = TextEditingController();
  
  final selectedStyleId = Rxn<int>();
  final selectedButtonId = Rxn<int>();
  final selectedThreadId = Rxn<int>();
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
    fetchGtgs();
    fetchDropdownData();
  }

  @override
  void onClose() {
    gtgNoController.dispose();
    sizeController.dispose();
    sleeveTypeController.dispose();
    colorController.dispose();
    consumptionController.dispose();
    targetController.dispose();
    super.onClose();
  }

  Future<void> fetchDropdownData() async {
    try {
      final stylesFuture = _apiService.getActiveStyles();
      final buttonsFuture = _apiService.getActiveButtons();
      final threadsFuture = _apiService.getActiveThreads();

      final results = await Future.wait([stylesFuture, buttonsFuture, threadsFuture]);
      
      styles.value = results[0] as List<StyleModel>;
      buttons.value = results[1] as List<ButtonModel>;
      threads.value = results[2] as List<ThreadModel>;
    } catch (e) {
      showMessage('Error loading dropdown data: ${e.toString()}', isError: true);
    }
  }

  Future<void> fetchGtgs() async {
    try {
      isLoading.value = true;
      final data = await _apiService.getAllGtgs();
      gtgs.value = data;
    } catch (e) {
      showMessage('Error fetching GTGs: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createGtg() async {
    if (gtgNoController.text.trim().isEmpty || selectedStyleId.value == null) {
      showMessage('GTG No and Style are required', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final gtg = GtgModel(
        gtgNo: gtgNoController.text.trim(),
        styleId: selectedStyleId.value!,
        buttonId: selectedButtonId.value,
        threadId: selectedThreadId.value,
        size: sizeController.text.trim().isEmpty ? null : sizeController.text.trim(),
        sleeveType: sleeveTypeController.text.trim().isEmpty ? null : sleeveTypeController.text.trim(),
        color: colorController.text.trim().isEmpty ? null : colorController.text.trim(),
        consumptionPerShirt: consumptionController.text.trim().isEmpty ? null : double.tryParse(consumptionController.text.trim()),
        noOfShirtsTarget: targetController.text.trim().isEmpty ? null : int.tryParse(targetController.text.trim()),
        status: selectedStatus.value,
      );

      final response = await _apiService.createGtg(gtg);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'GTG created successfully');
        clearForm();
        fetchGtgs();
      } else {
        showMessage(response['message'] ?? 'Failed to create GTG', isError: true);
      }
    } catch (e) {
      showMessage('Error creating GTG: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateGtg(int id) async {
    if (gtgNoController.text.trim().isEmpty || selectedStyleId.value == null) {
      showMessage('GTG No and Style are required', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final gtg = GtgModel(
        gtgId: id,
        gtgNo: gtgNoController.text.trim(),
        styleId: selectedStyleId.value!,
        buttonId: selectedButtonId.value,
        threadId: selectedThreadId.value,
        size: sizeController.text.trim().isEmpty ? null : sizeController.text.trim(),
        sleeveType: sleeveTypeController.text.trim().isEmpty ? null : sleeveTypeController.text.trim(),
        color: colorController.text.trim().isEmpty ? null : colorController.text.trim(),
        consumptionPerShirt: consumptionController.text.trim().isEmpty ? null : double.tryParse(consumptionController.text.trim()),
        noOfShirtsTarget: targetController.text.trim().isEmpty ? null : int.tryParse(targetController.text.trim()),
        status: selectedStatus.value,
      );

      final response = await _apiService.updateGtg(id, gtg);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'GTG updated successfully');
        clearForm();
        fetchGtgs();
      } else {
        showMessage(response['message'] ?? 'Failed to update GTG', isError: true);
      }
    } catch (e) {
      showMessage('Error updating GTG: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteGtg(int id) async {
    try {
      isLoading.value = true;
      final response = await _apiService.deleteGtg(id);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'GTG deleted successfully');
        fetchGtgs();
      } else {
        showMessage(response['message'] ?? 'Failed to delete GTG', isError: true);
      }
    } catch (e) {
      showMessage('Error deleting GTG: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void loadGtgForEdit(GtgModel gtg) {
    gtgNoController.text = gtg.gtgNo;
    selectedStyleId.value = gtg.styleId;
    selectedButtonId.value = gtg.buttonId;
    selectedThreadId.value = gtg.threadId;
    sizeController.text = gtg.size ?? '';
    sleeveTypeController.text = gtg.sleeveType ?? '';
    colorController.text = gtg.color ?? '';
    consumptionController.text = gtg.consumptionPerShirt?.toString() ?? '';
    targetController.text = gtg.noOfShirtsTarget?.toString() ?? '';
    selectedStatus.value = gtg.status;
  }

  void clearForm() {
    gtgNoController.clear();
    sizeController.clear();
    sleeveTypeController.clear();
    colorController.clear();
    consumptionController.clear();
    targetController.clear();
    selectedStyleId.value = null;
    selectedButtonId.value = null;
    selectedThreadId.value = null;
    selectedStatus.value = 'ACTIVE';
  }
}
