import 'dart:math' as math;

import 'package:digital_shores/app/presentation/pages/plot/models/plot_point.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlotMapBounds {
  const PlotMapBounds({
    required this.minLatitude,
    required this.maxLatitude,
    required this.minLongitude,
    required this.maxLongitude,
  });

  final double minLatitude;
  final double maxLatitude;
  final double minLongitude;
  final double maxLongitude;

  static const double _minimumSpan = 0.00002;

  factory PlotMapBounds.fromPoints(List<PlotPoint> points) {
    final minLatitude = points.map((point) => point.latitude).reduce(math.min);
    final maxLatitude = points.map((point) => point.latitude).reduce(math.max);
    final minLongitude =
        points.map((point) => point.longitude).reduce(math.min);
    final maxLongitude =
        points.map((point) => point.longitude).reduce(math.max);

    return PlotMapBounds(
      minLatitude: minLatitude,
      maxLatitude: maxLatitude,
      minLongitude: minLongitude,
      maxLongitude: maxLongitude,
    ).expandedForDisplay();
  }

  double get latitudeSpan => maxLatitude - minLatitude;
  double get longitudeSpan => maxLongitude - minLongitude;

  LatLng get center => LatLng(
        (minLatitude + maxLatitude) / 2,
        (minLongitude + maxLongitude) / 2,
      );

  PlotMapBounds expandedForDisplay() {
    final latitudePadding = math.max(latitudeSpan * 0.18, _minimumSpan);
    final longitudePadding = math.max(longitudeSpan * 0.18, _minimumSpan);

    return PlotMapBounds(
      minLatitude: minLatitude - latitudePadding,
      maxLatitude: maxLatitude + latitudePadding,
      minLongitude: minLongitude - longitudePadding,
      maxLongitude: maxLongitude + longitudePadding,
    );
  }

  LatLngBounds toGoogleBounds() {
    return LatLngBounds(
      southwest: LatLng(minLatitude, minLongitude),
      northeast: LatLng(maxLatitude, maxLongitude),
    );
  }
}

List<PlotPoint> collectVisiblePlotPoints({
  required List<PlotPoint> draftPoints,
  required Iterable<List<PlotPoint>> savedPlotPoints,
}) {
  return <PlotPoint>[
    for (final points in savedPlotPoints) ...points,
    ...draftPoints,
  ];
}
