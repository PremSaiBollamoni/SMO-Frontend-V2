import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smo_flutter/features/gm/data/api/master_data_api_service.dart';
import 'package:smo_flutter/features/gm/data/models/thread_model.dart';

class ThreadController extends GetxController {
  final MasterDataApiService _apiService = MasterDataApiService();

  final threads = <ThreadModel>[].obs;
  final isLoading = false.obs;

  final threadCodeController = TextEditingController();
  final threadNameController = TextEditingController();
  final colorCodeController = TextEditingController();
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
    fetchThreads();
  }

  @override
  void onClose() {
    threadCodeController.dispose();
    threadNameController.dispose();
    colorCodeController.dispose();
    super.onClose();
  }

  Future<void> fetchThreads() async {
    try {
      isLoading.value = true;
      final data = await _apiService.getAllThreads();
      threads.value = data;
    } catch (e) {
      showMessage('Error fetching threads: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createThread() async {
    if (threadCodeController.text.trim().isEmpty ||
        threadNameController.text.trim().isEmpty ||
        colorCodeController.text.trim().isEmpty) {
      showMessage('Please fill all required fields', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final thread = ThreadModel(
        threadCode: threadCodeController.text.trim(),
        threadName: threadNameController.text.trim(),
        colorCode: colorCodeController.text.trim(),
        status: selectedStatus.value,
      );

      final response = await _apiService.createThread(thread);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Thread created successfully');
        clearForm();
        fetchThreads();
      } else {
        showMessage(response['message'] ?? 'Failed to create thread', isError: true);
      }
    } catch (e) {
      showMessage('Error creating thread: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateThread(int id) async {
    if (threadCodeController.text.trim().isEmpty ||
        threadNameController.text.trim().isEmpty ||
        colorCodeController.text.trim().isEmpty) {
      showMessage('Please fill all required fields', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      final thread = ThreadModel(
        threadId: id,
        threadCode: threadCodeController.text.trim(),
        threadName: threadNameController.text.trim(),
        colorCode: colorCodeController.text.trim(),
        status: selectedStatus.value,
      );

      final response = await _apiService.updateThread(id, thread);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Thread updated successfully');
        clearForm();
        fetchThreads();
      } else {
        showMessage(response['message'] ?? 'Failed to update thread', isError: true);
      }
    } catch (e) {
      showMessage('Error updating thread: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteThread(int id) async {
    try {
      isLoading.value = true;
      final response = await _apiService.deleteThread(id);

      if (response['success'] == true) {
        showMessage(response['message'] ?? 'Thread deleted successfully');
        fetchThreads();
      } else {
        showMessage(response['message'] ?? 'Failed to delete thread', isError: true);
      }
    } catch (e) {
      showMessage('Error deleting thread: ${e.toString()}', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  void loadThreadForEdit(ThreadModel thread) {
    threadCodeController.text = thread.threadCode;
    threadNameController.text = thread.threadName;
    colorCodeController.text = thread.colorCode;
    selectedStatus.value = thread.status;
  }

  void clearForm() {
    threadCodeController.clear();
    threadNameController.clear();
    colorCodeController.clear();
    selectedStatus.value = 'ACTIVE';
  }
}
