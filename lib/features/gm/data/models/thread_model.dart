class ThreadModel {
  final int? threadId;
  final String threadCode;
  final String threadName;
  final String colorCode;
  final String status;

  ThreadModel({
    this.threadId,
    required this.threadCode,
    required this.threadName,
    required this.colorCode,
    required this.status,
  });

  factory ThreadModel.fromJson(Map<String, dynamic> json) {
    return ThreadModel(
      threadId: json['threadId'],
      threadCode: json['threadCode'] ?? '',
      threadName: json['threadName'] ?? '',
      colorCode: json['colorCode'] ?? '',
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (threadId != null) 'threadId': threadId,
      'threadCode': threadCode,
      'threadName': threadName,
      'colorCode': colorCode,
      'status': status,
    };
  }
}
