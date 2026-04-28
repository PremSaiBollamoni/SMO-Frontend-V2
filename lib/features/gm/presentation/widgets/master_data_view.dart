import 'package:flutter/material.dart';
import '../screens/style_management_screen.dart';
import '../screens/gtg_management_screen.dart';
import '../screens/button_management_screen.dart';
import '../screens/label_management_screen.dart';
import '../screens/machine_management_screen.dart';
import '../screens/thread_management_screen.dart';
import '../../../../core/theme/app_theme.dart';

class MasterDataView extends StatelessWidget {
  final String empId;

  const MasterDataView({super.key, required this.empId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh counts if needed
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Master Data Management',
              style: AppTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Manage foundational data for production operations',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _buildMasterDataListItem(
              context,
              icon: Icons.checkroom_outlined,
              title: 'Styles',
              subtitle: 'Manage garment styles',
              color: AppTheme.primary,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StyleManagementScreen(empId: empId),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildMasterDataListItem(
              context,
              icon: Icons.label_outline,
              title: 'GTG IDs',
              subtitle: 'Manage style variants',
              color: const Color(0xFF9C27B0),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GtgManagementScreen(empId: empId),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildMasterDataListItem(
              context,
              icon: Icons.radio_button_unchecked,
              title: 'Buttons',
              subtitle: 'Manage button types',
              color: const Color(0xFFFF9800),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ButtonManagementScreen(empId: empId),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildMasterDataListItem(
              context,
              icon: Icons.local_offer_outlined,
              title: 'Labels',
              subtitle: 'Manage label types',
              color: const Color(0xFF4CAF50),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LabelManagementScreen(empId: empId),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildMasterDataListItem(
              context,
              icon: Icons.precision_manufacturing_outlined,
              title: 'Machines',
              subtitle: 'Manage machines',
              color: const Color(0xFFF44336),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MachineManagementScreen(empId: empId),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildMasterDataListItem(
              context,
              icon: Icons.linear_scale_outlined,
              title: 'Threads',
              subtitle: 'Manage thread types',
              color: const Color(0xFF00BCD4),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ThreadManagementScreen(empId: empId),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterDataListItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
