/// Floor Insights Domain Model
class FloorInsightsModel {
  final int activeWipCount;
  final int bottleneckOperationCount;
  final String lineBalancingHint;

  FloorInsightsModel({
    required this.activeWipCount,
    required this.bottleneckOperationCount,
    required this.lineBalancingHint,
  });

  bool get isBalanced => bottleneckOperationCount == 0;

  String get aiInsight {
    if (bottleneckOperationCount > 0) {
      return 'AI detected $bottleneckOperationCount bottleneck operation(s). Consider reassigning operators from low-load operations to clear the backlog.';
    }
    return 'Production floor is balanced. No immediate action required.';
  }
}
