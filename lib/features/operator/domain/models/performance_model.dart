/// Performance Model - Represents operator performance metrics
class PerformanceModel {
  final int? operatorId;
  final int? activeTasks;
  final int? completedTasks;

  PerformanceModel({this.operatorId, this.activeTasks, this.completedTasks});

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceModel(
      operatorId: json['operatorId'] as int?,
      activeTasks: json['activeTasks'] as int?,
      completedTasks: json['completedTasks'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operatorId': operatorId,
      'activeTasks': activeTasks,
      'completedTasks': completedTasks,
    };
  }
}
