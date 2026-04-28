class GtgModel {
  final int? gtgId; // This is style_variant_id
  final String gtgNo; // This is gtg_id (String)
  final int styleId;
  final String? styleName; // For display
  final int? buttonId;
  final String? buttonName; // For display
  final int? threadId;
  final String? threadName; // For display
  final String? size;
  final String? sleeveType;
  final String? color;
  final double? consumptionPerShirt;
  final int? noOfShirtsTarget;
  final String status;

  GtgModel({
    this.gtgId,
    required this.gtgNo,
    required this.styleId,
    this.styleName,
    this.buttonId,
    this.buttonName,
    this.threadId,
    this.threadName,
    this.size,
    this.sleeveType,
    this.color,
    this.consumptionPerShirt,
    this.noOfShirtsTarget,
    required this.status,
  });

  factory GtgModel.fromJson(Map<String, dynamic> json) {
    return GtgModel(
      gtgId: json['styleVariantId'],
      gtgNo: json['gtgId'] ?? '',
      styleId: json['styleId'] ?? 0,
      styleName: json['styleName'],
      buttonId: json['buttonId'],
      buttonName: json['buttonName'],
      threadId: json['threadId'],
      threadName: json['threadName'],
      size: json['size'],
      sleeveType: json['sleeveType'],
      color: json['color'],
      consumptionPerShirt: json['consumptionPerShirt']?.toDouble(),
      noOfShirtsTarget: json['noOfShirtsTarget'],
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (gtgId != null) 'styleVariantId': gtgId,
      'gtgId': gtgNo,
      'styleId': styleId,
      if (buttonId != null) 'buttonId': buttonId,
      if (threadId != null) 'threadId': threadId,
      if (size != null) 'size': size,
      if (sleeveType != null) 'sleeveType': sleeveType,
      if (color != null) 'color': color,
      if (consumptionPerShirt != null) 'consumptionPerShirt': consumptionPerShirt,
      if (noOfShirtsTarget != null) 'noOfShirtsTarget': noOfShirtsTarget,
      'status': status,
    };
  }
}
