import 'package:flutter/material.dart';

/// Placeholder for Purchase workspace - to be implemented
class PurchaseWorkspacePlaceholder extends StatelessWidget {
  final String empId;
  final String employeeName;
  final String role;

  const PurchaseWorkspacePlaceholder({
    required this.empId,
    required this.employeeName,
    required this.role,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Workspace')),
      body: Center(
        child: Text('Purchase Workspace - To be implemented'),
      ),
    );
  }
}
