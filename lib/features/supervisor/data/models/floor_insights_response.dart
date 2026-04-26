import '../../domain/models/floor_insights_model.dart';

/// Floor Insights API Response DTO
class FloorInsightsResponse {
  final int activeWipCount;
  final int bottleneckOperationCount;
  final String lineBalancingHint;

  FloorInsightsResponse({
    required this.activeWipCount,
    required this.bottleneckOperationCount,
    required this.lineBalancingHint,
  });

  factory FloorInsightsResponse.fromJson(Map<String, dynamic> json) {
    return FloorInsightsResponse(
      activeWipCount: (json['activeWipCount'] ?? 0) as int,
      bottleneckOperationCount: (json['bottleneckOperationCount'] ?? 0) as int,
      lineBalancingHint: (json['lineBalancingHint'] ?? '-') as String,
    );
  }

  FloorInsightsModel toDomain() {
    return FloorInsightsModel(
      activeWipCount: activeWipCount,
      bottleneckOperationCount: bottleneckOperationCount,
      lineBalancingHint: lineBalancingHint,
    );
  }
}
