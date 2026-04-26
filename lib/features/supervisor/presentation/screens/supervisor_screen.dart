import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../login_screen.dart';
import '../../../../profile_tab.dart';
import '../controller/supervisor_controller.dart';
import '../widgets/dashboard_view.dart';
import '../widgets/operator_performance_view.dart';
import '../widgets/reassign_work_view.dart';
import 'qr_assignment_screen.dart';
import 'tracking_screen.dart';
import 'merging_screen.dart';
import '../../../../features/process_planner/presentation/widgets/approved_process_plans_view.dart';

/// Supervisor Screen - Activity-driven tab visibility.
/// Each tab is only shown if the user has the corresponding activity.
class SupervisorScreen extends StatefulWidget {
  final String empId;
  final String employeeName;
  final String role;
  final List<String> activities;

  const SupervisorScreen({
    super.key,
    required this.empId,
    required this.employeeName,
    required this.role,
    required this.activities,
  });

  @override
  State<SupervisorScreen> createState() => _SupervisorScreenState();
}

class _SupervisorScreenState extends State<SupervisorScreen> {
  int _currentTab = 0;
  late final SupervisorController _controller;
  late final List<_TabItem> _tabs;

  @override
  void initState() {
    super.initState();
    // Set employee ID in API client for authenticated requests
    ApiClient().setEmpId(widget.empId);
    _controller = Get.put(SupervisorController());
    _controller.initialize(widget.empId, widget.employeeName, widget.role);
    _controller.fetchFloorInsights();
    _tabs = _buildTabs();
  }

  @override
  void dispose() {
    Get.delete<SupervisorController>();
    super.dispose();
  }

  /// Build only the tabs the user has activity for
  List<_TabItem> _buildTabs() {
    final acts = widget.activities;
    final tabs = <_TabItem>[];

    if (acts.contains('SUPERVISOR_QR_ASSIGNMENT')) {
      tabs.add(_TabItem(Icons.qr_code_2_outlined, 'QR Assigning', const QrAssignmentScreen()));
    }
    if (acts.contains('SUPERVISOR_TRACKING')) {
      tabs.add(_TabItem(Icons.track_changes_outlined, 'Tracking', const TrackingScreen()));
    }
    if (acts.contains('SUPERVISOR_MERGING')) {
      tabs.add(_TabItem(Icons.merge_type_outlined, 'Merging', const MergingScreen()));
    }
    if (acts.contains('SUPERVISOR_MONITOR_WIP')) {
      tabs.add(_TabItem(Icons.dashboard_outlined, 'Monitor WIP', const DashboardView()));
    }
    if (acts.contains('SUPERVISOR_VIEW_OPERATOR_PERFORMANCE')) {
      tabs.add(_TabItem(Icons.speed_outlined, 'Operator Performance', const OperatorPerformanceView()));
    }
    if (acts.contains('SUPERVISOR_REASSIGN_WORK')) {
      tabs.add(_TabItem(Icons.swap_horiz_outlined, 'Reassign Work', const ReassignWorkView()));
    }
    if (acts.contains('PP_VIEW_ALL')) {
      tabs.add(_TabItem(
        Icons.account_tree_outlined,
        'Process Plans',
        ApprovedProcessPlansView(empId: widget.empId, activities: widget.activities),
      ));
    }
    // Profile always available
    tabs.add(_TabItem(Icons.person_outline, 'My Profile', ProfileTab(empId: widget.empId.trim())));

    return tabs;
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

  Widget _buildDrawerItem(int index) {
    final tab = _tabs[index];
    final selected = _currentTab == index;
    return ListTile(
      leading: Icon(
        tab.icon,
        color: selected ? AppTheme.primary : AppTheme.onSurfaceVariant,
      ),
      title: Text(
        tab.label,
        style: AppTheme.bodyMedium.copyWith(
          color: selected ? AppTheme.primary : AppTheme.onSurface,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: selected,
      onTap: () {
        Navigator.of(context).pop();
        setState(() => _currentTab = index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tabs.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No activities assigned.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role),
        actions: [
          IconButton(onPressed: _logout, tooltip: 'Logout', icon: const Icon(Icons.logout)),
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
                      const Icon(Icons.factory_outlined, color: Colors.white, size: 34),
                      const SizedBox(height: 10),
                      Text(
                        widget.employeeName,
                        style: AppTheme.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.role} • ID ${widget.empId}',
                        style: AppTheme.bodySmall.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              ...List.generate(_tabs.length, _buildDrawerItem),
              const Spacer(),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.error),
                title: Text(
                  'Logout',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.error, fontWeight: FontWeight.w700),
                ),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: _tabs[_currentTab].screen,
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  final Widget screen;
  const _TabItem(this.icon, this.label, this.screen);
}
