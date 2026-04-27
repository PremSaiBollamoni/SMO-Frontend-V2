class QrAssignmentModel {
  final String processPlanNumber;
  final String qrCode;
  final String style;
  final String size;
  final String gtgNumber;
  final String btnNumber;
  final String label;
  final String nextOperation;
  final int trayQuantity;
  final int? supervisorId;
  final String? notes;
  final String? orderNumber; // Added for order linkage

  QrAssignmentModel({
    required this.processPlanNumber,
    required this.qrCode,
    required this.style,
    required this.size,
    required this.gtgNumber,
    required this.btnNumber,
    required this.label,
    required this.nextOperation,
    required this.trayQuantity,
    this.supervisorId,
    this.notes,
    this.orderNumber,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'processPlanNumber': processPlanNumber.trim(),
      'qrCode': qrCode.trim(),
      'trayQuantity': trayQuantity,
      'supervisorId': supervisorId ?? 1004,
    };

    if (style.trim().isNotEmpty) {
      json['style'] = style.trim();
    }
    if (size.trim().isNotEmpty) {
      json['size'] = size.trim();
    }
    if (gtgNumber.trim().isNotEmpty) {
      json['gtgNumber'] = gtgNumber.trim();
    }
    if (btnNumber.trim().isNotEmpty) {
      json['btnNumber'] = btnNumber.trim();
    }
    if (label.trim().isNotEmpty) {
      json['label'] = label.trim();
    }
    if (nextOperation.trim().isNotEmpty) {
      json['nextOperation'] = nextOperation.trim();
    }
    if (notes != null && notes!.trim().isNotEmpty) {
      json['notes'] = notes!.trim();
    }
    if (orderNumber != null && orderNumber!.trim().isNotEmpty) {
      json['orderNumber'] = orderNumber!.trim();
    }

    return json;
  }

  factory QrAssignmentModel.fromJson(Map<String, dynamic> json) {
    return QrAssignmentModel(
      processPlanNumber: json['processPlanNumber'] ?? '',
      qrCode: json['qrCode'] ?? '',
      style: json['style'] ?? '',
      size: json['size'] ?? '',
      gtgNumber: json['gtgNumber'] ?? '',
      btnNumber: json['btnNumber'] ?? '',
      label: json['label'] ?? '',
      nextOperation: json['nextOperation'] ?? '',
      trayQuantity: json['trayQuantity'] ?? 1,
      supervisorId: json['supervisorId'],
      notes: json['notes'],
      orderNumber: json['orderNumber'],
    );
  }

  QrAssignmentModel copyWith({
    String? processPlanNumber,
    String? qrCode,
    String? style,
    String? size,
    String? gtgNumber,
    String? btnNumber,
    String? label,
    String? nextOperation,
    int? trayQuantity,
    int? supervisorId,
    String? notes,
    String? orderNumber,
  }) {
    return QrAssignmentModel(
      processPlanNumber: processPlanNumber ?? this.processPlanNumber,
      qrCode: qrCode ?? this.qrCode,
      style: style ?? this.style,
      size: size ?? this.size,
      gtgNumber: gtgNumber ?? this.gtgNumber,
      btnNumber: btnNumber ?? this.btnNumber,
      label: label ?? this.label,
      nextOperation: nextOperation ?? this.nextOperation,
      trayQuantity: trayQuantity ?? this.trayQuantity,
      supervisorId: supervisorId ?? this.supervisorId,
      notes: notes ?? this.notes,
      orderNumber: orderNumber ?? this.orderNumber,
    );
  }
}
