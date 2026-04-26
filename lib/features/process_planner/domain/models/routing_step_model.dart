/// Routing Step domain model
class RoutingStepModel {
  final int routingStepId;
  final int routingId;
  final int operationId;
  final int stageGroup;

  RoutingStepModel({
    required this.routingStepId,
    required this.routingId,
    required this.operationId,
    required this.stageGroup,
  });

  factory RoutingStepModel.fromJson(Map<String, dynamic> json) {
    return RoutingStepModel(
      routingStepId: json['routingStepId'] as int,
      routingId: json['routingId'] as int,
      operationId: json['operationId'] as int,
      stageGroup: json['stageGroup'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routingStepId': routingStepId,
      'routingId': routingId,
      'operationId': operationId,
      'stageGroup': stageGroup,
    };
  }
}
