class TrackingModel {
  final String machineQr;
  final String employeeQr;
  final String trayQr;
  final String status;
  final int? supervisorId; // Added for tracking who performed the action
  final int? operationId; // Current operation being completed

  TrackingModel({
    required this.machineQr,
    required this.employeeQr,
    required this.trayQr,
    required this.status,
    this.supervisorId,
    this.operationId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'machineQr': machineQr.trim(),
      'employeeQr': employeeQr.trim(),
      'trayQr': trayQr.trim(),
      'status': status.trim(),
    };

    // Only include supervisorId if it's not null
    if (supervisorId != null) {
      json['supervisorId'] = supervisorId;
    }

    // Only include operationId if it's not null
    if (operationId != null) {
      json['operationId'] = operationId;
    }

    return json;
  }

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      machineQr: json['machineQr'] ?? '',
      employeeQr: json['employeeQr'] ?? '',
      trayQr: json['trayQr'] ?? '',
      status: json['status'] ?? '',
      supervisorId: json['supervisorId'],
      operationId: json['operationId'],
    );
  }

  TrackingModel copyWith({
    String? machineQr,
    String? employeeQr,
    String? trayQr,
    String? status,
    int? supervisorId,
    int? operationId,
  }) {
    return TrackingModel(
      machineQr: machineQr ?? this.machineQr,
      employeeQr: employeeQr ?? this.employeeQr,
      trayQr: trayQr ?? this.trayQr,
      status: status ?? this.status,
      supervisorId: supervisorId ?? this.supervisorId,
      operationId: operationId ?? this.operationId,
    );
  }
}
