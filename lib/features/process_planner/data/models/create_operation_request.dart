/// Request model for creating an operation
class CreateOperationRequest {
  final int operationId;
  final String name;
  final int sequence;
  final int standardTime;
  final bool isParallel;
  final bool mergePoint;

  CreateOperationRequest({
    required this.operationId,
    required this.name,
    required this.sequence,
    required this.standardTime,
    required this.isParallel,
    required this.mergePoint,
  });

  Map<String, dynamic> toJson() {
    return {
      'operationId': operationId,
      'name': name,
      'sequence': sequence,
      'standardTime': standardTime,
      'isParallel': isParallel,
      'mergePoint': mergePoint,
    };
  }
}
