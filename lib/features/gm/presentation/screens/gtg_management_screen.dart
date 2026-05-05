import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smo_flutter/features/gm/presentation/controllers/gtg_controller.dart';
import 'package:smo_flutter/features/gm/data/models/gtg_model.dart';
import 'package:smo_flutter/core/theme/app_theme.dart';

class GtgManagementScreen extends StatelessWidget {
  final String empId;

  const GtgManagementScreen({super.key, required this.empId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GtgController());
    controller.setContext(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GTG Management'),
        actions: [
          IconButton(
            onPressed: controller.fetchGtgs,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.gtgs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.gtgs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.label_outline,
                    size: 64, color: AppTheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('No GTGs found', style: AppTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Tap + to create a new GTG',
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchGtgs,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.gtgs.length,
            itemBuilder: (context, index) {
              final gtg = controller.gtgs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: gtg.status == 'ACTIVE'
                        ? AppTheme.success.withOpacity(0.2)
                        : AppTheme.error.withOpacity(0.2),
                    child: Icon(
                      Icons.label_outline,
                      color: gtg.status == 'ACTIVE'
                          ? AppTheme.success
                          : AppTheme.error,
                    ),
                  ),
                  title: Text(gtg.gtgNo, style: AppTheme.titleMedium),
                  subtitle: Text(
                    '${gtg.styleName ?? 'Style #${gtg.styleId}'} • ${gtg.status}',
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showGtgDialog(
                          context,
                          controller,
                          gtg: gtg,
                        ),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppTheme.error,
                        onPressed: () => _confirmDelete(context, controller, gtg),
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
        onPressed: () => _showGtgDialog(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Add GTG'),
      ),
    );
  }

  void _showGtgDialog(
    BuildContext context,
    GtgController controller, {
    GtgModel? gtg,
  }) {
    final isEdit = gtg != null;
    if (isEdit) {
      controller.loadGtgForEdit(gtg);
    } else {
      controller.clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit GTG' : 'Add GTG'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.gtgNoController,
                decoration: const InputDecoration(
                  labelText: 'GTG No *',
                  hintText: 'e.g., GTG-001',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<int>(
                    value: controller.selectedStyleId.value,
                    decoration: const InputDecoration(
                      labelText: 'Style *',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select Style'),
                    items: controller.styles
                        .map((style) => DropdownMenuItem(
                              value: style.styleId,
                              child: Text(style.styleNo),
                            ))
                        .toList(),
                    onChanged: (value) {
                      controller.selectedStyleId.value = value;
                    },
                  )),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<int>(
                    value: controller.selectedButtonId.value,
                    decoration: const InputDecoration(
                      labelText: 'Button *',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select Button (Required)'),
                    items: controller.buttons
                        .map((button) => DropdownMenuItem(
                              value: button.buttonId,
                              child: Text(button.buttonName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      controller.selectedButtonId.value = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a button';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<int>(
                    value: controller.selectedThreadId.value,
                    decoration: const InputDecoration(
                      labelText: 'Thread *',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select Thread (Required)'),
                    items: controller.threads
                        .map((thread) => DropdownMenuItem(
                              value: thread.threadId,
                              child: Text(thread.threadName),
                            ))
                        .toList(),
                    onChanged: (value) {
                      controller.selectedThreadId.value = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a thread';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 16),
              TextField(
                controller: controller.sizeController,
                decoration: const InputDecoration(
                  labelText: 'Size',
                  hintText: 'e.g., M, L, XL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.sleeveTypeController,
                decoration: const InputDecoration(
                  labelText: 'Sleeve Type',
                  hintText: 'e.g., Full Sleeve',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  hintText: 'e.g., Blue',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.consumptionController,
                decoration: const InputDecoration(
                  labelText: 'Consumption Per Shirt',
                  hintText: 'e.g., 2.5',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.targetController,
                decoration: const InputDecoration(
                  labelText: 'No. of Shirts Target',
                  hintText: 'e.g., 100',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
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
                          await controller.updateGtg(gtg.gtgId!);
                        } else {
                          await controller.createGtg();
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
    GtgController controller,
    GtgModel gtg,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete GTG'),
        content: Text(
          'Are you sure you want to delete "${gtg.gtgNo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteGtg(gtg.gtgId!);
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
