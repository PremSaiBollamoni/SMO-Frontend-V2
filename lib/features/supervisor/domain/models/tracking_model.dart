class TrackingModel {
  final String machineQr;
  final String employeeQr;
  final String trayQr;
  final String status;
  final int? supervisorId; // Added for tracking who performed the action

  TrackingModel({
    required this.machineQr,
    required this.employeeQr,
    required this.trayQr,
    required this.status,
    this.supervisorId,
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

    return json;
  }

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      machineQr: json['machineQr'] ?? '',
      employeeQr: json['employeeQr'] ?? '',
      trayQr: json['trayQr'] ?? '',
      status: json['status'] ?? '',
      supervisorId: json['supervisorId'],
    );
  }

  TrackingModel copyWith({
    String? machineQr,
    String? employeeQr,
    String? trayQr,
    String? status,
    int? supervisorId,
  }) {
    return TrackingModel(
      machineQr: machineQr ?? this.machineQr,
      employeeQr: employeeQr ?? this.employeeQr,
      trayQr: trayQr ?? this.trayQr,
      status: status ?? this.status,
      supervisorId: supervisorId ?? this.supervisorId,
    );
  }
}
