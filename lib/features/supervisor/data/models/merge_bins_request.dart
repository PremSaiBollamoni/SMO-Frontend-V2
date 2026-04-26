/// Merge Bins Request DTO
class MergeBinsRequest {
  final int targetBundleId;
  final int sourceBundleId;

  MergeBinsRequest({
    required this.targetBundleId,
    required this.sourceBundleId,
  });

  Map<String, dynamic> toJson() {
    return {'targetBundleId': targetBundleId, 'sourceBundleId': sourceBundleId};
  }
}
