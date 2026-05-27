import 'dart:math' as math;

import 'package:digital_shores/app/presentation/pages/plot/models/plot_point.dart';
import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:flutter/material.dart';

class PlotOverviewItem {
  const PlotOverviewItem({
    required this.index,
    required this.plot,
    required this.path,
    required this.labelOffset,
    required this.center,
  });

  final int index;
  final SavedPlot plot;
  final Path path;
  final Offset labelOffset;
  final Offset center;
}

class PlotOverviewLayout {
  static const Size canvasSize = Size(1400, 1400);
  static const double padding = 120;

  static List<PlotOverviewItem> build(List<SavedPlot> plots) {
    if (plots.isEmpty) {
      return const <PlotOverviewItem>[];
    }

    final allPoints = plots.expand((plot) => plot.points).toList();
    final minLat = allPoints.map((p) => p.latitude).reduce(math.min);
    final maxLat = allPoints.map((p) => p.latitude).reduce(math.max);
    final minLng = allPoints.map((p) => p.longitude).reduce(math.min);
    final maxLng = allPoints.map((p) => p.longitude).reduce(math.max);

    var latRange = maxLat - minLat;
    var lngRange = maxLng - minLng;
    if (latRange == 0) latRange = 0.0001;
    if (lngRange == 0) lngRange = 0.0001;

    final usableWidth = canvasSize.width - padding * 2;
    final usableHeight = canvasSize.height - padding * 2;
    final scale = math.min(
      usableWidth / lngRange,
      usableHeight / latRange,
    );
    final contentWidth = lngRange * scale;
    final contentHeight = latRange * scale;
    final offsetX = (canvasSize.width - contentWidth) / 2;
    final offsetY = (canvasSize.height - contentHeight) / 2;

    Offset mapPoint(PlotPoint point) {
      final x = offsetX + (point.longitude - minLng) * scale;
      final y = canvasSize.height - offsetY - (point.latitude - minLat) * scale;
      return Offset(x, y);
    }

    return plots.asMap().entries.map((entry) {
      final index = entry.key;
      final plot = entry.value;
      final mappedPoints = plot.points.map(mapPoint).toList();
      final path = Path()..moveTo(mappedPoints.first.dx, mappedPoints.first.dy);
      for (var i = 1; i < mappedPoints.length; i++) {
        path.lineTo(mappedPoints[i].dx, mappedPoints[i].dy);
      }
      path.close();

      final center = _calculateCenter(mappedPoints);
      return PlotOverviewItem(
        index: index,
        plot: plot,
        path: path,
        labelOffset: center,
        center: center,
      );
    }).toList();
  }

  static Offset _calculateCenter(List<Offset> points) {
    if (points.isEmpty) {
      return Offset.zero;
    }

    final dx = points.fold<double>(0, (sum, point) => sum + point.dx);
    final dy = points.fold<double>(0, (sum, point) => sum + point.dy);
    return Offset(dx / points.length, dy / points.length);
  }
}
