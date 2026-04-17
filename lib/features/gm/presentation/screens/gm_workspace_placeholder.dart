import 'package:flutter/material.dart';

/// Placeholder for GM workspace - to be implemented
class GmWorkspacePlaceholder extends StatelessWidget {
  final String empId;
  final String employeeName;
  final String role;

  const GmWorkspacePlaceholder({
    required this.empId,
    required this.employeeName,
    required this.role,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GM Workspace')),
      body: Center(
        child: Text('GM Workspace - To be implemented'),
      ),
    );
  }
}
