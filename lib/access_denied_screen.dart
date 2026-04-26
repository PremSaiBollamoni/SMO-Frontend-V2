import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'login_screen.dart';

class AccessDeniedScreen extends StatelessWidget {
  final String message;
  final String? roleName;
  final String? activities;
  final Function(bool)? setDarkMode;

  const AccessDeniedScreen({
    super.key,
    required this.message,
    this.roleName,
    this.activities,
    this.setDarkMode,
  });

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen(setDarkMode: setDarkMode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryVariant],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              decoration: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkCardDecoration
                  : AppTheme.cardDecoration,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Error Icon
                    const Icon(Icons.block, size: 80, color: AppTheme.error),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Access Denied',
                      style: AppTheme.headlineLarge.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkOnSurface
                            : AppTheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Message
                    Text(
                      message,
                      style: AppTheme.bodyLarge.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkOnSurfaceVariant
                            : AppTheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Role Info (if available)
                    if (roleName != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.darkSurfaceVariant
                              : AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Role: $roleName',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppTheme.darkOnSurface
                                    : AppTheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Activities: ${activities?.isEmpty ?? true ? "None assigned" : activities}',
                              style: AppTheme.bodySmall.copyWith(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppTheme.darkOnSurfaceVariant
                                    : AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Instructions
                    Text(
                      'Please contact your HR department or system administrator to get the necessary permissions assigned to your role.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkOnSurfaceVariant
                            : AppTheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Logout Button
                    ElevatedButton(
                      onPressed: () => _logout(context),
                      style: AppTheme.primaryButtonStyle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 16.0,
                        ),
                        child: Text(
                          'LOGOUT',
                          style: AppTheme.labelLarge.copyWith(
                            color: AppTheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
