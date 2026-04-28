class LabelModel {
  final int? labelId;
  final String labelCode;
  final String labelName;
  final String labelType;
  final String? description;
  final String status;

  LabelModel({
    this.labelId,
    required this.labelCode,
    required this.labelName,
    required this.labelType,
    this.description,
    required this.status,
  });

  factory LabelModel.fromJson(Map<String, dynamic> json) {
    return LabelModel(
      labelId: json['labelId'],
      labelCode: json['labelCode'] ?? '',
      labelName: json['labelName'] ?? '',
      labelType: json['labelType'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (labelId != null) 'labelId': labelId,
      'labelCode': labelCode,
      'labelName': labelName,
      'labelType': labelType,
      if (description != null) 'description': description,
      'status': status,
    };
  }
}
