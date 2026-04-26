import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../login_screen.dart';
import '../../../../profile_tab.dart';
import '../controller/operator_controller.dart';
import '../widgets/start_work_view.dart';
import '../widgets/complete_work_view.dart';
import '../widgets/assigned_tasks_view.dart';
import '../widgets/performance_view.dart';

/// Operator Screen - Main workspace for operators
class OperatorScreen extends StatefulWidget {
  final String empId;
  final String employeeName;
  final String role;

  const OperatorScreen({
    super.key,
    required this.empId,
    required this.employeeName,
    required this.role,
  });

  @override
  State<OperatorScreen> createState() => _OperatorScreenState();
}

class _OperatorScreenState extends State<OperatorScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    final controller = Get.put(OperatorController());
    controller.initialize(widget.empId, widget.employeeName, widget.role);
    controller.fetchTasks();
    controller.fetchPerformance();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ApiClient().clearEmpId();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _drawerItem(IconData icon, String label, int index) {
    final selected = _selectedTab == index;
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? AppTheme.primary : AppTheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: AppTheme.bodyMedium.copyWith(
          color: selected ? AppTheme.primary : AppTheme.onSurface,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: selected,
      onTap: () {
        Navigator.of(context).pop();
        setState(() => _selectedTab = index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const StartWorkView(),
      const CompleteWorkView(),
      const AssignedTasksView(),
      const PerformanceView(),
      ProfileTab(empId: widget.empId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operator Workspace'),
        actions: [
          IconButton(
            onPressed: _logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${widget.employeeName} • EMP ${widget.empId}',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.onPrimary),
              ),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryVariant],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.precision_manufacturing,
                        color: Colors.white,
                        size: 34,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.employeeName,
                        style: AppTheme.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Operator • ID ${widget.empId}',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _drawerItem(Icons.play_circle_outline, 'Start Work', 0),
              _drawerItem(Icons.task_alt_outlined, 'Complete Work', 1),
              _drawerItem(Icons.assignment_outlined, 'Assigned Tasks', 2),
              _drawerItem(Icons.insights_outlined, 'Performance', 3),
              _drawerItem(Icons.person_outline, 'My Profile', 4),
              const Spacer(),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.error),
                title: Text(
                  'Logout',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: tabs[_selectedTab],
    );
  }
}
