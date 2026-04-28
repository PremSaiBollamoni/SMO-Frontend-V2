import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smo_flutter/features/gm/presentation/controllers/style_controller.dart';
import 'package:smo_flutter/features/gm/data/models/style_model.dart';
import 'package:smo_flutter/core/theme/app_theme.dart';

class StyleManagementScreen extends StatelessWidget {
  final String empId;

  const StyleManagementScreen({super.key, required this.empId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StyleController());
    controller.setContext(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Style Management'),
        actions: [
          IconButton(
            onPressed: controller.fetchStyles,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.styles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.styles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.checkroom_outlined,
                    size: 64, color: AppTheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('No styles found', style: AppTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Tap + to create a new style',
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchStyles,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.styles.length,
            itemBuilder: (context, index) {
              final style = controller.styles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: style.status == 'ACTIVE'
                        ? AppTheme.success.withOpacity(0.2)
                        : AppTheme.error.withOpacity(0.2),
                    child: Icon(
                      Icons.checkroom_outlined,
                      color: style.status == 'ACTIVE'
                          ? AppTheme.success
                          : AppTheme.error,
                    ),
                  ),
                  title: Text(style.styleNo, style: AppTheme.titleMedium),
                  subtitle: Text(
                    '${style.concept ?? 'No concept'} • ${style.status}',
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showStyleDialog(
                          context,
                          controller,
                          style: style,
                        ),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppTheme.error,
                        onPressed: () => _confirmDelete(context, controller, style),
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
        onPressed: () => _showStyleDialog(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Add Style'),
      ),
    );
  }

  void _showStyleDialog(
    BuildContext context,
    StyleController controller, {
    StyleModel? style,
  }) {
    final isEdit = style != null;
    if (isEdit) {
      controller.loadStyleForEdit(style);
    } else {
      controller.clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Style' : 'Add Style'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.styleNoController,
                decoration: const InputDecoration(
                  labelText: 'Style No *',
                  hintText: 'e.g., STY-001',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.conceptController,
                decoration: const InputDecoration(
                  labelText: 'Concept',
                  hintText: 'e.g., Casual Wear',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.mainLabelController,
                decoration: const InputDecoration(
                  labelText: 'Main Label',
                  hintText: 'Main label name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.brandingLabelController,
                decoration: const InputDecoration(
                  labelText: 'Branding Label',
                  hintText: 'Branding label name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.patternImageController,
                decoration: const InputDecoration(
                  labelText: 'Pattern Image',
                  hintText: 'Image URL or path',
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
                          await controller.updateStyle(style.styleId!);
                        } else {
                          await controller.createStyle();
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
    StyleController controller,
    StyleModel style,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Style'),
        content: Text(
          'Are you sure you want to delete "${style.styleNo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteStyle(style.styleId!);
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
