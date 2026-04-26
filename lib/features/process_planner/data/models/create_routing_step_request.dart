/// Request model for creating a routing step
class CreateRoutingStepRequest {
  final int routingStepId;
  final int routingId;
  final int operationId;
  final int stageGroup;

  CreateRoutingStepRequest({
    required this.routingStepId,
    required this.routingId,
    required this.operationId,
    required this.stageGroup,
  });

  Map<String, dynamic> toJson() {
    return {
      'routingStepId': routingStepId,
      'routingId': routingId,
      'operationId': operationId,
      'stageGroup': stageGroup,
    };
  }
}
