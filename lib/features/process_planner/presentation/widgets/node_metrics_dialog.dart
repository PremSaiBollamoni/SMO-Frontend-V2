import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

/// Read-only dialog showing 3 live metrics for a workflow node.
/// Auto-refreshes every 30 seconds while open.
class NodeMetricsDialog extends StatefulWidget {
  final int routingId;
  final int operationId;
  final String operationName;
  final String empId;

  const NodeMetricsDialog({
    super.key,
    required this.routingId,
    required this.operationId,
    required this.operationName,
    required this.empId,
  });

  @override
  State<NodeMetricsDialog> createState() => _NodeMetricsDialogState();
}

class _NodeMetricsDialogState extends State<NodeMetricsDialog> {
  static const _refreshInterval = Duration(seconds: 30);

  bool _loading = true;
  String? _error;
  int _wipCount = 0;
  int _jobsBeingProcessed = 0;
  int _jobsProcessedToday = 0;
  Timer? _timer;
  DateTime? _lastUpdated;
  bool _fetching = false; // Guard against overlapping requests

  @override
  void initState() {
    super.initState();
    _fetchMetrics();
    // Auto-refresh every 30 seconds
    _timer = Timer.periodic(_refreshInterval, (_) => _fetchMetrics());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMetrics() async {
    if (_fetching) return; // Skip if previous request still in flight
    _fetching = true;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient().dio.get(
        '/api/processplan/node-metrics',
        queryParameters: {
          'routingId': widget.routingId,
          'operationId': widget.operationId,
          'actorEmpId': widget.empId,
        },
      );
      if (!mounted) return;
      final data = res.data as Map<String, dynamic>;
      setState(() {
        _wipCount = (data['wip_count'] as num?)?.toInt() ?? 0;
        _jobsBeingProcessed = (data['jobs_being_processed'] as num?)?.toInt() ?? 0;
        _jobsProcessedToday = (data['jobs_processed_today'] as num?)?.toInt() ?? 0;
        _lastUpdated = DateTime.now();
        _loading = false;
        _fetching = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.response?.data?['message']?.toString() ?? 'Failed to load metrics';
        _loading = false;
        _fetching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load metrics';
        _loading = false;
        _fetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildBody(dark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.operationName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool dark) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 36),
            const SizedBox(height: 12),
            Text(_error!, style: AppTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _fetchMetrics,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _metricRow(
            icon: Icons.inventory_2_outlined,
            color: AppTheme.primary,
            label: 'WIP at this stage',
            value: _wipCount,
            dark: dark,
          ),
          const SizedBox(height: 12),
          _metricRow(
            icon: Icons.play_circle_outline,
            color: AppTheme.secondary,
            label: 'Jobs being processed',
            value: _jobsBeingProcessed,
            dark: dark,
          ),
          const SizedBox(height: 12),
          _metricRow(
            icon: Icons.check_circle_outline,
            color: AppTheme.success,
            label: 'Jobs processed today',
            value: _jobsProcessedToday,
            dark: dark,
          ),
          const SizedBox(height: 8),
          if (_lastUpdated != null)
            Text(
              'Updated ${_lastUpdated!.hour.toString().padLeft(2, '0')}:${_lastUpdated!.minute.toString().padLeft(2, '0')}:${_lastUpdated!.second.toString().padLeft(2, '0')} • auto-refreshes every 30s',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _metricRow({
    required IconData icon,
    required Color color,
    required String label,
    required int value,
    required bool dark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: dark ? AppTheme.darkSurfaceVariant : color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTheme.bodyMedium),
          ),
          Text(
            '$value',
            style: AppTheme.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
