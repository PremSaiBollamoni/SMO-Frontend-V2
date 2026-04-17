import 'package:flutter/material.dart';

/// Placeholder for QC workspace - to be implemented
class QcWorkspacePlaceholder extends StatelessWidget {
  final String empId;
  final String employeeName;
  final String role;

  const QcWorkspacePlaceholder({
    required this.empId,
    required this.employeeName,
    required this.role,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QC Workspace')),
      body: Center(
        child: Text('QC Workspace - To be implemented'),
      ),
    );
  }
}
