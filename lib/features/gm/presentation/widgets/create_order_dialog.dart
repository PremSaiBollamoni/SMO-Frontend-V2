import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/order_model.dart';
import '../controller/order_controller.dart';
import '../../../../core/network/api_client.dart';

/// Dialog for creating new orders
class CreateOrderDialog extends StatefulWidget {
  final String empId;
  final VoidCallback? onOrderCreated;

  const CreateOrderDialog({
    super.key,
    required this.empId,
    this.onOrderCreated,
  });

  @override
  State<CreateOrderDialog> createState() => _CreateOrderDialogState();
}

class _CreateOrderDialogState extends State<CreateOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _orderNumberController = TextEditingController();
  final _orderQtyController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _expectedDateController = TextEditingController();
  
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _approvedRoutings = [];
  
  int? _selectedProductId;
  int? _selectedRoutingId;
  bool _isLoading = false;
  bool _isLoadingProducts = true;
  bool _isLoadingRoutings = false;

  @override
  void initState() {
    super.initState();
    _selectedProductId = null;
    _selectedRoutingId = null;
    _loadProducts();
    _generateOrderNumber();
  }

  @override
  void dispose() {
    _orderNumberController.dispose();
    _orderQtyController.dispose();
    _customerNameController.dispose();
    _expectedDateController.dispose();
    super.dispose();
  }

  void _generateOrderNumber() {
    final now = DateTime.now();
    final orderNum = 'ORD-${now.year}-${now.millisecondsSinceEpoch.toString().substring(8)}';
    _orderNumberController.text = orderNum;
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      debugPrint('[CREATE_ORDER] Fetching products from /api/production/products');
      final response = await ApiClient().dio.get('/api/production/products');
      debugPrint('[CREATE_ORDER] Response status: ${response.statusCode}');
      debugPrint('[CREATE_ORDER] Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        final rawProducts = List<Map<String, dynamic>>.from(response.data);
        debugPrint('[CREATE_ORDER] Raw products count: ${rawProducts.length}');
        
        // Deduplicate by productId (backend uses camelCase)
        final seenIds = <int>{};
        final uniqueProducts = <Map<String, dynamic>>[];
        for (final product in rawProducts) {
          final id = product['productId'] as int?; // Changed from 'product_id' to 'productId'
          if (id != null && !seenIds.contains(id)) {
            seenIds.add(id);
            uniqueProducts.add(product);
          } else if (id != null) {
            debugPrint('WARNING: Duplicate productId found: $id');
          } else {
            debugPrint('WARNING: Product with null productId: $product');
          }
        }
        
        debugPrint('[CREATE_ORDER] Unique products count: ${uniqueProducts.length}');
        
        setState(() {
          _products = uniqueProducts;
          _isLoadingProducts = false;
          // Reset selection if current selection no longer exists
          if (_selectedProductId != null && !_products.any((p) => p['productId'] == _selectedProductId)) {
            _selectedProductId = null;
            _selectedRoutingId = null;
            _approvedRoutings = [];
          }
        });
        
        debugPrint('[CREATE_ORDER] Products loaded successfully: ${_products.length} products');
      } else {
        debugPrint('[CREATE_ORDER] Invalid response: status=${response.statusCode}, data=${response.data}');
        setState(() => _isLoadingProducts = false);
      }
    } catch (e, stackTrace) {
      debugPrint('[CREATE_ORDER] ERROR loading products: $e');
      debugPrint('[CREATE_ORDER] Stack trace: $stackTrace');
      setState(() => _isLoadingProducts = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products: $e')),
        );
      }
    }
  }

  Future<void> _loadApprovedRoutings(int productId) async {
    setState(() {
      _isLoadingRoutings = true;
      _selectedRoutingId = null;
      _approvedRoutings = [];
    });
    
    try {
      debugPrint('[CREATE_ORDER] Fetching routings from /api/processplan/approved for productId=$productId');
      final response = await ApiClient().dio.get(
        '/api/processplan/approved',
        queryParameters: {
          'actorEmpId': widget.empId,
        },
      );
      
      debugPrint('[CREATE_ORDER] Routings response status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data != null) {
        final allRoutings = List<Map<String, dynamic>>.from(response.data);
        debugPrint('[CREATE_ORDER] All routings count: ${allRoutings.length}');
        
        // Backend uses snake_case: product_id, routing_id
        final filteredRoutings = allRoutings
            .where((r) => r['product_id'] == productId)
            .toList();
        debugPrint('[CREATE_ORDER] Filtered routings for productId=$productId: ${filteredRoutings.length}');
        
        // Deduplicate by routing_id
        final seenIds = <int>{};
        final uniqueRoutings = <Map<String, dynamic>>[];
        for (final routing in filteredRoutings) {
          final id = routing['routing_id'] as int?;
          if (id != null && !seenIds.contains(id)) {
            seenIds.add(id);
            uniqueRoutings.add(routing);
          } else if (id != null) {
            debugPrint('WARNING: Duplicate routing_id found: $id');
          }
        }
        
        debugPrint('[CREATE_ORDER] Unique routings count: ${uniqueRoutings.length}');
        
        setState(() {
          _approvedRoutings = uniqueRoutings;
          _isLoadingRoutings = false;
          // Reset selection if current selection no longer exists
          if (_selectedRoutingId != null && !_approvedRoutings.any((r) => r['routing_id'] == _selectedRoutingId)) {
            _selectedRoutingId = null;
          }
        });
      }
    } catch (e, stackTrace) {
      debugPrint('[CREATE_ORDER] ERROR loading routings: $e');
      debugPrint('[CREATE_ORDER] Stack trace: $stackTrace');
      setState(() {
        _approvedRoutings = [];
        _selectedRoutingId = null;
        _isLoadingRoutings = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load approved routings: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      _expectedDateController.text = picked.toString().split(' ')[0];
    }
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product')),
      );
      return;
    }
    
    if (_selectedRoutingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a process plan')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      debugPrint('[CREATE_ORDER] Creating order with productId=$_selectedProductId, routingId=$_selectedRoutingId');
      
      final controller = Get.find<OrderController>();
      final order = OrderModel(
        orderNumber: _orderNumberController.text.trim(),
        productId: _selectedProductId!,
        routingId: _selectedRoutingId!,
        orderQty: int.parse(_orderQtyController.text.trim()),
        expectedCompletionDate: _expectedDateController.text.isNotEmpty 
            ? _expectedDateController.text 
            : null,
        customerName: _customerNameController.text.trim().isNotEmpty 
            ? _customerNameController.text.trim() 
            : null,
        status: 'DRAFT',
        createdBy: int.parse(widget.empId),
      );
      
      debugPrint('[CREATE_ORDER] Order model: ${order.toJson()}');
      
      await controller.createOrder(order, widget.empId);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order ${order.orderNumber} created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onOrderCreated?.call();
      }
    } catch (e, stackTrace) {
      debugPrint('[CREATE_ORDER] ERROR creating order: $e');
      debugPrint('[CREATE_ORDER] Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create New Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Number
                      TextFormField(
                        controller: _orderNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Order Number *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.tag),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Order number is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Product Selection
                      if (_isLoadingProducts)
                        const Center(child: CircularProgressIndicator())
                      else if (_products.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No products available'),
                        )
                      else
                        Builder(
                          builder: (context) {
                            // Guard: ensure value exists in items, otherwise null
                            final productValue = _products.any((p) => p['productId'] == _selectedProductId) 
                                ? _selectedProductId 
                                : null;
                            
                            return DropdownButtonFormField<int>(
                              value: productValue,
                              decoration: const InputDecoration(
                                labelText: 'Product *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              hint: const Text('Select a product'),
                              items: _products.map((product) {
                                return DropdownMenuItem<int>(
                                  value: product['productId'], // Changed from 'product_id' to 'productId'
                                  child: Text(product['name'] ?? 'Product #${product['productId']}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedProductId = value;
                                  _selectedRoutingId = null;
                                  _approvedRoutings = [];
                                });
                                if (value != null) {
                                  _loadApprovedRoutings(value);
                                }
                              },
                              validator: (value) {
                                if (_selectedProductId == null) {
                                  return 'Please select a product';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Process Plan Selection
                      if (_selectedProductId != null) ...[
                        if (_isLoadingRoutings)
                          const Center(child: CircularProgressIndicator())
                        else if (_approvedRoutings.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No approved process plans found for this product'),
                          )
                        else
                          Builder(
                            builder: (context) {
                              // Guard: ensure value exists in items, otherwise null
                              final routingValue = _approvedRoutings.any((r) => r['routing_id'] == _selectedRoutingId)
                                  ? _selectedRoutingId
                                  : null;
                              
                              return DropdownButtonFormField<int>(
                                value: routingValue,
                                decoration: const InputDecoration(
                                  labelText: 'Process Plan (Approved) *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.account_tree),
                                ),
                                hint: const Text('Select a process plan'),
                                items: _approvedRoutings.map((routing) {
                                  return DropdownMenuItem<int>(
                                    value: routing['routing_id'],
                                    child: Text('Routing #${routing['routing_id']} (v${routing['version'] ?? 1})'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedRoutingId = value);
                                },
                                validator: (value) {
                                  if (_selectedRoutingId == null) {
                                    return 'Please select a process plan';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Order Quantity
                      TextFormField(
                        controller: _orderQtyController,
                        decoration: const InputDecoration(
                          labelText: 'Order Quantity *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.inventory_2),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Order quantity is required';
                          }
                          final qty = int.tryParse(value.trim());
                          if (qty == null || qty <= 0) {
                            return 'Please enter a valid quantity';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Expected Completion Date
                      TextFormField(
                        controller: _expectedDateController,
                        decoration: InputDecoration(
                          labelText: 'Expected Completion Date',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: _selectDate,
                          ),
                        ),
                        readOnly: true,
                        onTap: _selectDate,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Customer Name
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _createOrder,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Order'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
