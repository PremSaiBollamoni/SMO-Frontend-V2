import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smo_flutter/features/gm/presentation/controllers/button_controller.dart';
import 'package:smo_flutter/features/gm/data/models/button_model.dart';
import 'package:smo_flutter/core/theme/app_theme.dart';

class ButtonManagementScreen extends StatelessWidget {
  final String empId;

  const ButtonManagementScreen({super.key, required this.empId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ButtonController());
    // Pass context to controller for snackbars
    controller.setContext(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Button Management'),
        actions: [
          IconButton(
            onPressed: controller.fetchButtons,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.buttons.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.buttons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.radio_button_unchecked,
                    size: 64, color: AppTheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('No buttons found', style: AppTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Tap + to create a new button',
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchButtons,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.buttons.length,
            itemBuilder: (context, index) {
              final button = controller.buttons[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: button.status == 'ACTIVE'
                        ? AppTheme.success.withOpacity(0.2)
                        : AppTheme.error.withOpacity(0.2),
                    child: Icon(
                      Icons.radio_button_unchecked,
                      color: button.status == 'ACTIVE'
                          ? AppTheme.success
                          : AppTheme.error,
                    ),
                  ),
                  title: Text(button.buttonName, style: AppTheme.titleMedium),
                  subtitle: Text(
                    '${button.buttonCode} • ${button.status}',
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showButtonDialog(
                          context,
                          controller,
                          button: button,
                        ),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppTheme.error,
                        onPressed: () => _confirmDelete(context, controller, button),
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
        onPressed: () => _showButtonDialog(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Add Button'),
      ),
    );
  }

  void _showButtonDialog(
    BuildContext context,
    ButtonController controller, {
    ButtonModel? button,
  }) {
    final isEdit = button != null;
    if (isEdit) {
      controller.loadButtonForEdit(button);
    } else {
      controller.clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Button' : 'Add Button'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.buttonCodeController,
                decoration: const InputDecoration(
                  labelText: 'Button Code *',
                  hintText: 'e.g., BTN-001',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.buttonNameController,
                decoration: const InputDecoration(
                  labelText: 'Button Name *',
                  hintText: 'e.g., Plastic Round Button',
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
                          await controller.updateButton(button.buttonId!);
                        } else {
                          await controller.createButton();
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
    ButtonController controller,
    ButtonModel button,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Button'),
        content: Text(
          'Are you sure you want to delete "${button.buttonName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteButton(button.buttonId!);
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
