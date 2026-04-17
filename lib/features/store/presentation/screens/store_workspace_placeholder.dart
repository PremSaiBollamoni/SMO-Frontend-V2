import 'package:flutter/material.dart';

/// Placeholder for Store workspace - to be implemented
class StoreWorkspacePlaceholder extends StatelessWidget {
  final String empId;
  final String employeeName;
  final String role;

  const StoreWorkspacePlaceholder({
    required this.empId,
    required this.employeeName,
    required this.role,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Workspace')),
      body: Center(
        child: Text('Store Workspace - To be implemented'),
      ),
    );
  }
}
