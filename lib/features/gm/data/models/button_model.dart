class ButtonModel {
  final int? buttonId;
  final String buttonCode;
  final String buttonName;
  final String status;

  ButtonModel({
    this.buttonId,
    required this.buttonCode,
    required this.buttonName,
    required this.status,
  });

  factory ButtonModel.fromJson(Map<String, dynamic> json) {
    return ButtonModel(
      buttonId: json['buttonId'],
      buttonCode: json['buttonCode'] ?? '',
      buttonName: json['buttonName'] ?? '',
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (buttonId != null) 'buttonId': buttonId,
      'buttonCode': buttonCode,
      'buttonName': buttonName,
      'status': status,
    };
  }
}
