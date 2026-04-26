/// Operation domain model
class OperationModel {
  final int operationId;
  final String name;
  final int sequence;
  final int standardTime;
  final bool isParallel;
  final bool mergePoint;

  OperationModel({
    required this.operationId,
    required this.name,
    required this.sequence,
    required this.standardTime,
    required this.isParallel,
    required this.mergePoint,
  });

  factory OperationModel.fromJson(Map<String, dynamic> json) {
    return OperationModel(
      operationId: json['operationId'] as int,
      name: json['name'] as String? ?? '',
      sequence: json['sequence'] as int? ?? 0,
      standardTime: json['standardTime'] as int? ?? 0,
      isParallel: json['isParallel'] as bool? ?? false,
      mergePoint: json['mergePoint'] as bool? ?? false,
    );
  }

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
