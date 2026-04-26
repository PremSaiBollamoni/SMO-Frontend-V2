import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../../login_screen.dart';
import '../../../../profile_tab.dart';
import '../controller/store_controller.dart';
import '../widgets/inventory_view.dart';
import '../widgets/manage_inventory_view.dart';
import '../widgets/stock_levels_view.dart';
import '../widgets/issue_material_view.dart';
import '../widgets/stock_movements_view.dart';
import '../widgets/items_view.dart';
import '../widgets/grn_view.dart';

/// Store Screen - Main workspace for store managers
class StoreScreen extends StatefulWidget {
  final String empId;
  final String employeeName;
  final String role;

  const StoreScreen({
    super.key,
    required this.empId,
    required this.employeeName,
    required this.role,
  });

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    final controller = Get.put(StoreController());
    controller.initialize(widget.empId, widget.employeeName, widget.role);
    controller.refreshAll();
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

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedTab == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primary : AppTheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: AppTheme.bodyMedium.copyWith(
          color: isSelected ? AppTheme.primary : AppTheme.onSurface,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.of(context).pop();
        setState(() => _selectedTab = index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      const InventoryView(),
      const ManageInventoryView(),
      const StockLevelsView(),
      const IssueMaterialView(),
      const StockMovementsView(),
      const ItemsView(),
      const GrnView(),
      ProfileTab(empId: widget.empId),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Manager Workspace'),
        actions: [
          IconButton(
            onPressed: _logout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(42),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
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
                        Icons.warehouse,
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
                        'Store Manager • ID ${widget.empId}',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _drawerItem(
                icon: Icons.inventory_2_outlined,
                label: 'Inventory',
                index: 0,
              ),
              _drawerItem(
                icon: Icons.edit_note_outlined,
                label: 'Manage Inventory',
                index: 1,
              ),
              _drawerItem(
                icon: Icons.stacked_bar_chart_outlined,
                label: 'Stock Levels',
                index: 2,
              ),
              _drawerItem(
                icon: Icons.outbox_outlined,
                label: 'Issue Material',
                index: 3,
              ),
              _drawerItem(
                icon: Icons.swap_horiz_outlined,
                label: 'Stock Movements',
                index: 4,
              ),
              _drawerItem(
                icon: Icons.category_outlined,
                label: 'Items',
                index: 5,
              ),
              _drawerItem(
                icon: Icons.local_shipping_outlined,
                label: 'Receive Goods (GRN)',
                index: 6,
              ),
              _drawerItem(
                icon: Icons.person_outline,
                label: 'My Profile',
                index: 7,
              ),
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
