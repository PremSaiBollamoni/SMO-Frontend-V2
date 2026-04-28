class StyleModel {
  final int? styleId;
  final String styleNo;
  final String? concept;
  final String? mainLabel;
  final String? brandingLabel;
  final String? patternImage;
  final String? description;
  final String status;
  final String? createdAt;

  StyleModel({
    this.styleId,
    required this.styleNo,
    this.concept,
    this.mainLabel,
    this.brandingLabel,
    this.patternImage,
    this.description,
    required this.status,
    this.createdAt,
  });

  factory StyleModel.fromJson(Map<String, dynamic> json) {
    return StyleModel(
      styleId: json['styleId'],
      styleNo: json['styleNo'] ?? '',
      concept: json['concept'],
      mainLabel: json['mainLabel'],
      brandingLabel: json['brandingLabel'],
      patternImage: json['patternImage'],
      description: json['description'],
      status: json['status'] ?? 'ACTIVE',
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (styleId != null) 'styleId': styleId,
      'styleNo': styleNo,
      if (concept != null) 'concept': concept,
      if (mainLabel != null) 'mainLabel': mainLabel,
      if (brandingLabel != null) 'brandingLabel': brandingLabel,
      if (patternImage != null) 'patternImage': patternImage,
      if (description != null) 'description': description,
      'status': status,
    };
  }
}
