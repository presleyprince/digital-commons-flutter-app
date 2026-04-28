class PlotPoint {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime recordedAt;

  const PlotPoint({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.recordedAt,
  });

  Map<String, Object?> toMap({
    required String plotId,
    required int pointOrder,
  }) {
    return {
      'plot_id': plotId,
      'point_order': pointOrder,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'recorded_at': recordedAt.millisecondsSinceEpoch,
    };
  }

  factory PlotPoint.fromMap(Map<String, Object?> map) {
    return PlotPoint(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      accuracy: (map['accuracy'] as num).toDouble(),
      recordedAt: DateTime.fromMillisecondsSinceEpoch(map['recorded_at'] as int),
    );
  }
}
