class MachineModel {
  final int? machineId;
  final String machineName;
  final String machineType;
  final String status;

  MachineModel({
    this.machineId,
    required this.machineName,
    required this.machineType,
    required this.status,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) {
    return MachineModel(
      machineId: json['machineId'],
      machineName: json['name'] ?? '',
      machineType: json['type'] ?? '',
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (machineId != null) 'machineId': machineId,
      'name': machineName,
      'type': machineType,
      'status': status,
    };
  }
}
