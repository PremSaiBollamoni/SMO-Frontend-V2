import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smo_flutter/features/gm/presentation/controllers/thread_controller.dart';
import 'package:smo_flutter/features/gm/data/models/thread_model.dart';
import 'package:smo_flutter/core/theme/app_theme.dart';

class ThreadManagementScreen extends StatelessWidget {
  final String empId;

  const ThreadManagementScreen({super.key, required this.empId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ThreadController());
    controller.setContext(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread Management'),
        actions: [
          IconButton(
            onPressed: controller.fetchThreads,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.threads.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.threads.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.linear_scale_outlined,
                    size: 64, color: AppTheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('No threads found', style: AppTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Tap + to create a new thread',
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchThreads,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.threads.length,
            itemBuilder: (context, index) {
              final thread = controller.threads[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: thread.status == 'ACTIVE'
                        ? AppTheme.success.withOpacity(0.2)
                        : AppTheme.error.withOpacity(0.2),
                    child: Icon(
                      Icons.linear_scale_outlined,
                      color: thread.status == 'ACTIVE'
                          ? AppTheme.success
                          : AppTheme.error,
                    ),
                  ),
                  title: Text(thread.threadName, style: AppTheme.titleMedium),
                  subtitle: Text(
                    '${thread.threadCode} • ${thread.colorCode} • ${thread.status}',
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showThreadDialog(
                          context,
                          controller,
                          thread: thread,
                        ),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppTheme.error,
                        onPressed: () => _confirmDelete(context, controller, thread),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showThreadDialog(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Add Thread'),
      ),
    );
  }

  void _showThreadDialog(
    BuildContext context,
    ThreadController controller, {
    ThreadModel? thread,
  }) {
    final isEdit = thread != null;
    if (isEdit) {
      controller.loadThreadForEdit(thread);
    } else {
      controller.clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Thread' : 'Add Thread'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.threadCodeController,
                decoration: const InputDecoration(
                  labelText: 'Thread Code *',
                  hintText: 'e.g., THR-001',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.threadNameController,
                decoration: const InputDecoration(
                  labelText: 'Thread Name *',
                  hintText: 'e.g., Polyester Thread',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.colorCodeController,
                decoration: const InputDecoration(
                  labelText: 'Color Code *',
                  hintText: 'e.g., #FF5733',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedStatus.value,
                    decoration: const InputDecoration(
                      labelText: 'Status *',
                      border: OutlineInputBorder(),
                    ),
                    items: ['ACTIVE', 'INACTIVE']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedStatus.value = value;
                      }
                    },
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearForm();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        if (isEdit) {
                          await controller.updateThread(thread.threadId!);
                        } else {
                          await controller.createThread();
                        }
                        if (!controller.isLoading.value) {
                          Navigator.pop(context);
                        }
                      },
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEdit ? 'Update' : 'Create'),
              )),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ThreadController controller,
    ThreadModel thread,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Thread'),
        content: Text(
          'Are you sure you want to delete "${thread.threadName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteThread(thread.threadId!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
