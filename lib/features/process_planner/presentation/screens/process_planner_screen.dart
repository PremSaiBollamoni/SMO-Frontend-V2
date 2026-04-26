import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../login_screen.dart';
import '../controller/process_planner_controller.dart';
import '../widgets/process_planner_sidebar.dart';
import '../widgets/process_planner_top_bar.dart';
import '../widgets/dashboard_view.dart';
import '../widgets/products_view.dart';
import '../widgets/operations_view.dart';
import '../widgets/routings_view.dart';
import '../widgets/routing_steps_view.dart';
import '../widgets/profile_view.dart';
import '../widgets/create_product_dialog.dart';
import '../widgets/create_operation_dialog.dart';
import '../widgets/create_routing_dialog.dart';
import '../widgets/create_routing_step_dialog.dart';

/// Process Planner Screen - Clean Architecture Implementation
class ProcessPlannerScreen extends StatefulWidget {
  final String empId;
  final String employeeName;
  final String role;

  const ProcessPlannerScreen({
    super.key,
    required this.empId,
    required this.employeeName,
    required this.role,
  });

  @override
  State<ProcessPlannerScreen> createState() => _ProcessPlannerScreenState();
}

class _ProcessPlannerScreenState extends State<ProcessPlannerScreen>
    with SingleTickerProviderStateMixin {
  final ProcessPlannerController _controller = Get.put(
    ProcessPlannerController(),
  );
  int _selectedMenu = 0;
  bool _isSidebarVisible = false;
  late AnimationController _sidebarAnimationController;
  late Animation<Offset> _sidebarSlideAnimation;

  @override
  void initState() {
    super.initState();
    _sidebarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sidebarSlideAnimation =
        Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _sidebarAnimationController,
            curve: Curves.easeInOut,
          ),
        );
    _loadSessionAndData();
  }

  @override
  void dispose() {
    _sidebarAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadSessionAndData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeName =
          prefs.getString('EMPLOYEE_NAME') ?? widget.employeeName;
      final empId = prefs.getString('EMP_ID') ?? widget.empId;

      ApiClient().setEmpId(empId);
      _controller.initialize(empId, employeeName);
      await _controller.refreshAll();
    } catch (e) {
      debugPrint('Session load error: $e');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  String _getPageTitle() {
    switch (_selectedMenu) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Products';
      case 2:
        return 'Operations';
      case 3:
        return 'Routings';
      case 4:
        return 'Routing Steps';
      case 5:
        return 'My Profile';
      default:
        return 'Process Planner';
    }
  }

  Future<void> _showCreateProductDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => CreateProductDialog(
        onCreateProduct:
            ({
              required int productId,
              required String name,
              required String category,
              required String status,
            }) async {
              final success = await _controller.createProduct(
                productId: productId,
                name: name,
                category: category,
                status: status,
              );

              if (!mounted) return success;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              return success;
            },
      ),
    );
  }

  Future<void> _showCreateOperationDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => CreateOperationDialog(
        onCreateOperation:
            ({
              required int operationId,
              required String name,
              required String description,
              required int sequence,
              required int standardTime,
              required bool isParallel,
              required bool mergePoint,
              required int stageGroup,
            }) async {
              final success = await _controller.createOperation(
                operationId: operationId,
                name: name,
                sequence: sequence,
                standardTime: standardTime,
                isParallel: isParallel,
                mergePoint: mergePoint,
              );

              if (!mounted) return success;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Operation created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              return success;
            },
      ),
    );
  }

  Future<void> _showCreateRoutingDialog() async {
    // Ensure products are loaded
    await _controller.fetchProducts();

    if (_controller.products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a product first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => CreateRoutingDialog(
        onCreateRouting:
            ({
              required int routingId,
              required int productId,
              required int version,
              required String status,
              required String approvalStatus,
            }) async {
              final success = await _controller.createRouting(
                routingId: routingId,
                productId: productId,
                version: version,
                status: status,
                approvalStatus: approvalStatus,
              );

              if (!mounted) return success;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Routing created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              return success;
            },
      ),
    );
  }

  Future<void> _showCreateRoutingStepDialog() async {
    // Ensure routings and operations are loaded
    await Future.wait([
      _controller.fetchRoutings(),
      _controller.fetchOperations(),
    ]);

    if (_controller.routings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a routing first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_controller.operations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create an operation first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => CreateRoutingStepDialog(
        onCreateRoutingStep:
            ({
              required int routingStepId,
              required int routingId,
              required int operationId,
              required int stageGroup,
            }) async {
              final success = await _controller.createRoutingStep(
                routingStepId: routingStepId,
                routingId: routingId,
                operationId: operationId,
                stageGroup: stageGroup,
              );

              if (!mounted) return success;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Routing step created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              return success;
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                ProcessPlannerTopBar(
                  isSidebarVisible: _isSidebarVisible,
                  onToggleSidebar: () {
                    setState(() => _isSidebarVisible = !_isSidebarVisible);
                    if (_isSidebarVisible) {
                      _sidebarAnimationController.forward();
                    } else {
                      _sidebarAnimationController.reverse();
                    }
                  },
                  pageTitle: _getPageTitle(),
                ),
                Expanded(child: _buildContent()),
              ],
            ),
            if (_isSidebarVisible)
              Positioned(
                left: 250,
                top: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() => _isSidebarVisible = false);
                    _sidebarAnimationController.reverse();
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
            if (_isSidebarVisible)
              SlideTransition(
                position: _sidebarSlideAnimation,
                child: Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: ProcessPlannerSidebar(
                    selectedMenu: _selectedMenu,
                    onMenuSelected: (index) =>
                        setState(() => _selectedMenu = index),
                    onLogout: _logout,
                    isVisible: _isSidebarVisible,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _selectedMenu >= 1 && _selectedMenu <= 4
          ? FloatingActionButton(
              onPressed: () {
                switch (_selectedMenu) {
                  case 1:
                    _showCreateProductDialog();
                    break;
                  case 2:
                    _showCreateOperationDialog();
                    break;
                  case 3:
                    _showCreateRoutingDialog();
                    break;
                  case 4:
                    _showCreateRoutingStepDialog();
                    break;
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildContent() {
    switch (_selectedMenu) {
      case 0:
        return const DashboardView();
      case 1:
        return const ProductsView();
      case 2:
        return const OperationsView();
      case 3:
        return const RoutingsView();
      case 4:
        return const RoutingStepsView();
      case 5:
        return const ProfileView();
      default:
        return const DashboardView();
    }
  }
}
