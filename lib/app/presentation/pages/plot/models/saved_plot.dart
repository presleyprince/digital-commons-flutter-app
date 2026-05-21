import 'package:digital_shores/app/presentation/pages/plot/models/plot_point.dart';

class SavedPlot {
  final String id;
  final String name;
  final List<PlotPoint> points;
  final double areaSquareMeters;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final String source;

  const SavedPlot({
    required this.id,
    required this.name,
    required this.points,
    required this.areaSquareMeters,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.source,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'area_square_meters': areaSquareMeters,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_synced': isSynced ? 1 : 0,
      'source': source,
    };
  }

  factory SavedPlot.fromMap(Map<String, Object?> map, List<PlotPoint> points) {
    return SavedPlot(
      id: map['id'] as String,
      name: map['name'] as String,
      points: points,
      areaSquareMeters: (map['area_square_meters'] as num).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isSynced: (map['is_synced'] as int) == 1,
      source: map['source'] as String,
    );
  }

  SavedPlot copyWith({
    String? id,
    String? name,
    List<PlotPoint>? points,
    double? areaSquareMeters,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? source,
  }) {
    return SavedPlot(
      id: id ?? this.id,
      name: name ?? this.name,
      points: points ?? this.points,
      areaSquareMeters: areaSquareMeters ?? this.areaSquareMeters,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      source: source ?? this.source,
    );
  }
}
