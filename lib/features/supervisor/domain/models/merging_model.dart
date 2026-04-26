class MergingModel {
  final String tub1Qr;
  final String tub1Description;
  final String tub2Qr;
  final String tub2Description;
  final int? supervisorId; // Added for enhanced workflow
  final String? notes; // Added for enhanced workflow

  MergingModel({
    required this.tub1Qr,
    required this.tub1Description,
    required this.tub2Qr,
    required this.tub2Description,
    this.supervisorId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'tub1Qr': tub1Qr.trim(),
      'tub1Description': tub1Description.trim(),
      'tub2Qr': tub2Qr.trim(),
      'tub2Description': tub2Description.trim(),
      'supervisorId': supervisorId ?? 1004, // Default supervisor ID
    };

    // Only include notes if it's not null and not empty
    if (notes != null && notes!.trim().isNotEmpty) {
      json['notes'] = notes!.trim();
    }

    return json;
  }

  factory MergingModel.fromJson(Map<String, dynamic> json) {
    return MergingModel(
      tub1Qr: json['tub1Qr'] ?? '',
      tub1Description: json['tub1Description'] ?? '',
      tub2Qr: json['tub2Qr'] ?? '',
      tub2Description: json['tub2Description'] ?? '',
      supervisorId: json['supervisorId'],
      notes: json['notes'],
    );
  }

  MergingModel copyWith({
    String? tub1Qr,
    String? tub1Description,
    String? tub2Qr,
    String? tub2Description,
    int? supervisorId,
    String? notes,
  }) {
    return MergingModel(
      tub1Qr: tub1Qr ?? this.tub1Qr,
      tub1Description: tub1Description ?? this.tub1Description,
      tub2Qr: tub2Qr ?? this.tub2Qr,
      tub2Description: tub2Description ?? this.tub2Description,
      supervisorId: supervisorId ?? this.supervisorId,
      notes: notes ?? this.notes,
    );
  }
}
