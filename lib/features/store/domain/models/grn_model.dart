/// GRN (Goods Receipt Note) Model
class GrnModel {
  final int? grnId;
  final int? poId;
  final String? date;
  final String? status;

  GrnModel({this.grnId, this.poId, this.date, this.status});

  factory GrnModel.fromJson(Map<String, dynamic> json) {
    return GrnModel(
      grnId: json['grnId'] as int?,
      poId: json['poId'] as int?,
      date: json['date'] as String?,
      status: json['status'] as String?,
    );
  }
}
