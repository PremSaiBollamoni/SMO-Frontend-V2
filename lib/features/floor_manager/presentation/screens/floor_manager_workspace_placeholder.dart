import 'package:flutter/material.dart';

/// Placeholder for Floor Manager workspace - to be implemented
class FloorManagerWorkspacePlaceholder extends StatelessWidget {
  final String empId;
  final String employeeName;
  final String role;

  const FloorManagerWorkspacePlaceholder({
    required this.empId,
    required this.employeeName,
    required this.role,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Floor Manager Workspace')),
      body: Center(
        child: Text('Floor Manager Workspace - To be implemented'),
      ),
    );
  }
}
