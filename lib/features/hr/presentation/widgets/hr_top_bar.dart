import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// HR Top bar widget with hamburger menu
class HrTopBar extends StatelessWidget {
  final bool isSidebarVisible;
  final VoidCallback onToggleSidebar;
  final String pageTitle;

  const HrTopBar({
    super.key,
    required this.isSidebarVisible,
    required this.onToggleSidebar,
    required this.pageTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hamburger menu button with white color
          IconButton(
            icon: Icon(
              isSidebarVisible ? Icons.menu_open : Icons.menu,
              color: Colors.white,
              size: 28,
            ),
            onPressed: onToggleSidebar,
            tooltip: isSidebarVisible ? 'Hide Sidebar' : 'Show Sidebar',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              pageTitle,
              style: AppTheme.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
