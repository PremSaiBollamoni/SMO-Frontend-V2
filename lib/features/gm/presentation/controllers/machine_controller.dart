import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smo_flutter/features/gm/data/api/master_data_api_service.dart';
import 'package:smo_flutter/features/gm/data/models/machine_model.dart';

class MachineController extends GetxController {
  final MasterDataApiService _apiService = MasterDataApiService();

  final machines = <MachineModel>[].obs;
  final isLoading = false.obs;

  final machineNameController = TextEditingController();
  final machineTypeController = TextEditingController();
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
    fetchMachines();
  }

  @override
  void onClose() {
    machineNameController.dispose();
    machineTypeController.dispose();
    super.onClose();
  }

  Future<void> fetchMachines() async {
    try {
      isLoading.value = true;
      final data = await _apiService.getAllMachines();
      machines.value = data;
    } catch (e) {
      showMessage('Error fetching machines: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createMachine() async {
    if (machineNameController.text.trim().isEmpty ||
        machineTypeController.text.trim().isEmpty) {
      showMessage('Please fill all required fields', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final machine = MachineModel(
        machineName: machineNameController.text.trim(),
        machineType: machineTypeController.text.trim(),
        status: selectedStatus.value,
      );

      final response = await _apiService.createMachine(machine);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Machine created successfully');
        clearForm();
        fetchMachines();
      } else {
        showMessage(response['message'] ?? 'Failed to create machine', isError: true);
      }
    } catch (e) {
      showMessage('Error creating machine: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateMachine(int id) async {
    if (machineNameController.text.trim().isEmpty ||
        machineTypeController.text.trim().isEmpty) {
      showMessage('Please fill all required fields', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final machine = MachineModel(
        machineId: id,
        machineName: machineNameController.text.trim(),
        machineType: machineTypeController.text.trim(),
        status: selectedStatus.value,
      );

      final response = await _apiService.updateMachine(id, machine);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Machine updated successfully');
        clearForm();
        fetchMachines();
      } else {
        showMessage(response['message'] ?? 'Failed to update machine', isError: true);
      }
    } catch (e) {
      showMessage('Error updating machine: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMachine(int id) async {
    try {
      isLoading.value = true;
      final response = await _apiService.deleteMachine(id);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Machine deleted successfully');
        fetchMachines();
      } else {
        showMessage(response['message'] ?? 'Failed to delete machine', isError: true);
      }
    } catch (e) {
      showMessage('Error deleting machine: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void loadMachineForEdit(MachineModel machine) {
    machineNameController.text = machine.machineName;
    machineTypeController.text = machine.machineType;
    selectedStatus.value = machine.status;
  }

  void clearForm() {
    machineNameController.clear();
    machineTypeController.clear();
    selectedStatus.value = 'ACTIVE';
  }
}
