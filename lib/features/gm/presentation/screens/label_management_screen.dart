import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smo_flutter/features/gm/presentation/controllers/label_controller.dart';
import 'package:smo_flutter/features/gm/data/models/label_model.dart';
import 'package:smo_flutter/core/theme/app_theme.dart';

class LabelManagementScreen extends StatelessWidget {
  final String empId;

  const LabelManagementScreen({super.key, required this.empId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LabelController());
    controller.setContext(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Label Management'),
        actions: [
          IconButton(
            onPressed: controller.fetchLabels,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.labels.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.labels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer_outlined,
                    size: 64, color: AppTheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('No labels found', style: AppTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Tap + to create a new label',
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchLabels,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.labels.length,
            itemBuilder: (context, index) {
              final label = controller.labels[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: label.status == 'ACTIVE'
                        ? AppTheme.success.withOpacity(0.2)
                        : AppTheme.error.withOpacity(0.2),
                    child: Icon(
                      Icons.local_offer_outlined,
                      color: label.status == 'ACTIVE'
                          ? AppTheme.success
                          : AppTheme.error,
                    ),
                  ),
                  title: Text(label.labelName, style: AppTheme.titleMedium),
                  subtitle: Text(
                    '${label.labelCode} • ${label.labelType} • ${label.status}',
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showLabelDialog(
                          context,
                          controller,
                          label: label,
                        ),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppTheme.error,
                        onPressed: () => _confirmDelete(context, controller, label),
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
        onPressed: () => _showLabelDialog(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Add Label'),
      ),
    );
  }

  void _showLabelDialog(
    BuildContext context,
    LabelController controller, {
    LabelModel? label,
  }) {
    final isEdit = label != null;
    if (isEdit) {
      controller.loadLabelForEdit(label);
    } else {
      controller.clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Label' : 'Add Label'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.labelCodeController,
                decoration: const InputDecoration(
                  labelText: 'Label Code *',
                  hintText: 'e.g., LBL-001',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.labelNameController,
                decoration: const InputDecoration(
                  labelText: 'Label Name *',
                  hintText: 'e.g., Main Label',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.labelTypeController,
                decoration: const InputDecoration(
                  labelText: 'Label Type *',
                  hintText: 'e.g., Woven',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
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
                          await controller.updateLabel(label.labelId!);
                        } else {
                          await controller.createLabel();
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
    LabelController controller,
    LabelModel label,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Label'),
        content: Text(
          'Are you sure you want to delete "${label.labelName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteLabel(label.labelId!);
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
