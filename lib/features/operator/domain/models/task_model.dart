/// Task Model - Represents an assigned task
class TaskModel {
  final int? wipId;
  final int? bundleId;
  final int? operationId;
  final int? machineId;
  final int? qty;
  final String? startTime;

  TaskModel({
    this.wipId,
    this.bundleId,
    this.operationId,
    this.machineId,
    this.qty,
    this.startTime,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      wipId: json['wipId'] as int?,
      bundleId: json['bundleId'] as int?,
      operationId: json['operationId'] as int?,
      machineId: json['machineId'] as int?,
      qty: json['qty'] as int?,
      startTime: json['startTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wipId': wipId,
      'bundleId': bundleId,
      'operationId': operationId,
      'machineId': machineId,
      'qty': qty,
      'startTime': startTime,
    };
  }
}
