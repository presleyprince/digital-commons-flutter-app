import 'dart:math' as math;

import 'package:digital_shores/app/presentation/pages/plot/models/plot_point.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PlotGeometry {
  static const int requiredPointCount = 4;

  static bool isTooCloseToLastRecordedPoint({
    required List<PlotPoint> points,
    required Position currentPosition,
    double minDistanceMeters = 3,
  }) {
    if (points.isEmpty) return false;

    final lastPoint = points.last;
    final distanceInMeters = Geolocator.distanceBetween(
      lastPoint.latitude,
      lastPoint.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    return distanceInMeters < minDistanceMeters;
  }

  static double calculatePolygonAreaSquareMeters(List<PlotPoint> points) {
    if (points.length < requiredPointCount) {
      return 0;
    }

    final p1 = points[0];
    final p2 = points[1];
    final p3 = points[2];
    final p4 = points[3];

    final side12 = _distanceBetweenPoints(p1, p2);
    final side23 = _distanceBetweenPoints(p2, p3);
    final side34 = _distanceBetweenPoints(p3, p4);
    final side41 = _distanceBetweenPoints(p4, p1);
    final diagonal13 = _distanceBetweenPoints(p1, p3);

    final firstTriangleArea = _calculateTriangleArea(
      side12,
      side23,
      diagonal13,
    );
    final secondTriangleArea = _calculateTriangleArea(
      diagonal13,
      side34,
      side41,
    );

    return firstTriangleArea + secondTriangleArea;
  }

  static List<Offset> mapPointsToCanvas(List<PlotPoint> sourcePoints, Size size) {
    final minLat = sourcePoints.map((p) => p.latitude).reduce(math.min);
    final maxLat = sourcePoints.map((p) => p.latitude).reduce(math.max);
    final minLng = sourcePoints.map((p) => p.longitude).reduce(math.min);
    final maxLng = sourcePoints.map((p) => p.longitude).reduce(math.max);

    double latRange = maxLat - minLat;
    double lngRange = maxLng - minLng;

    if (latRange == 0) latRange = 0.0001;
    if (lngRange == 0) lngRange = 0.0001;

    const padding = 80.0;
    final usableWidth = size.width - padding * 2;
    final usableHeight = size.height - padding * 2;

    return sourcePoints.map((point) {
      final x = padding + ((point.longitude - minLng) / lngRange) * usableWidth;
      final y = size.height -
          padding -
          ((point.latitude - minLat) / latRange) * usableHeight;
      return Offset(x, y);
    }).toList();
  }

  static double degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  static double _distanceBetweenPoints(PlotPoint first, PlotPoint second) {
    return Geolocator.distanceBetween(
      first.latitude,
      first.longitude,
      second.latitude,
      second.longitude,
    );
  }

  static double _calculateTriangleArea(double a, double b, double c) {
    final semiPerimeter = (a + b + c) / 2;
    final radicand = semiPerimeter *
        (semiPerimeter - a) *
        (semiPerimeter - b) *
        (semiPerimeter - c);

    if (radicand <= 0) {
      return 0;
    }

    return math.sqrt(radicand);
  }
}
