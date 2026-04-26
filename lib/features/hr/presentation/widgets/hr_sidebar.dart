import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/hr_controller.dart';

/// HR Sidebar widget - overlay style
class HrSidebar extends StatelessWidget {
  final int selectedMenu;
  final Function(int) onMenuSelected;
  final VoidCallback onLogout;
  final bool isVisible;

  const HrSidebar({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
    required this.onLogout,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HrController>();

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : AppTheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: AppTheme.primary),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Text(
                    controller.employeeName.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'HR Manager',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSidebarItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  index: 0,
                ),
                _buildSidebarItem(icon: Icons.work, label: 'Roles', index: 1),
                _buildSidebarItem(
                  icon: Icons.people,
                  label: 'Employees',
                  index: 2,
                ),
                _buildSidebarItem(
                  icon: Icons.person,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          // Logout button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: onLogout,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = selectedMenu == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onTap: () => onMenuSelected(index),
      ),
    );
  }
}
