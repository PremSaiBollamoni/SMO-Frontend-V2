import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smo_flutter/features/gm/presentation/controllers/machine_controller.dart';
import 'package:smo_flutter/features/gm/data/models/machine_model.dart';
import 'package:smo_flutter/core/theme/app_theme.dart';

class MachineManagementScreen extends StatelessWidget {
  final String empId;

  const MachineManagementScreen({super.key, required this.empId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MachineController());
    controller.setContext(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Machine Management'),
        actions: [
          IconButton(
            onPressed: controller.fetchMachines,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.machines.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.machines.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.precision_manufacturing_outlined,
                    size: 64, color: AppTheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('No machines found', style: AppTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Tap + to create a new machine',
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchMachines,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.machines.length,
            itemBuilder: (context, index) {
              final machine = controller.machines[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: machine.status == 'ACTIVE'
                        ? AppTheme.success.withOpacity(0.2)
                        : AppTheme.error.withOpacity(0.2),
                    child: Icon(
                      Icons.precision_manufacturing_outlined,
                      color: machine.status == 'ACTIVE'
                          ? AppTheme.success
                          : AppTheme.error,
                    ),
                  ),
                  title: Text(machine.machineName, style: AppTheme.titleMedium),
                  subtitle: Text(
                    '${machine.machineType} • ${machine.status}',
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showMachineDialog(
                          context,
                          controller,
                          machine: machine,
                        ),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppTheme.error,
                        onPressed: () => _confirmDelete(context, controller, machine),
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
        onPressed: () => _showMachineDialog(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('Add Machine'),
      ),
    );
  }

  void _showMachineDialog(
    BuildContext context,
    MachineController controller, {
    MachineModel? machine,
  }) {
    final isEdit = machine != null;
    if (isEdit) {
      controller.loadMachineForEdit(machine);
    } else {
      controller.clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Machine' : 'Add Machine'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller.machineNameController,
                decoration: const InputDecoration(
                  labelText: 'Machine Name *',
                  hintText: 'e.g., Juki DDL-8700',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.machineTypeController,
                decoration: const InputDecoration(
                  labelText: 'Machine Type *',
                  hintText: 'e.g., Single Needle',
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
                          await controller.updateMachine(machine.machineId!);
                        } else {
                          await controller.createMachine();
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
    MachineController controller,
    MachineModel machine,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Machine'),
        content: Text(
          'Are you sure you want to delete "${machine.machineName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteMachine(machine.machineId!);
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
