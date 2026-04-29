import 'dart:math' as math;

import 'package:digital_shores/app/presentation/pages/plot/models/plot_point.dart';
import 'package:digital_shores/app/presentation/pages/plot/utils/plot_geometry.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PlotPreviewPainter extends CustomPainter {
  final List<PlotPoint> points;
  final Position? currentPosition;

  PlotPreviewPainter({
    required this.points,
    required this.currentPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y <= size.height; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.isEmpty && currentPosition == null) return;

    final previewPoints = <PlotPoint>[
      ...points,
      if (currentPosition != null)
        PlotPoint(
          latitude: currentPosition!.latitude,
          longitude: currentPosition!.longitude,
          accuracy: currentPosition!.accuracy,
          recordedAt: DateTime.now(),
        ),
    ];

    final mappedPreviewPoints = PlotGeometry.mapPointsToCanvas(previewPoints, size);
    final mappedRecordedPoints =
        mappedPreviewPoints.take(points.length).toList();

    final linePaint = Paint()
      ..color = Colors.blue.shade700
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;

    final recordedPointPaint = Paint()
      ..color = Colors.red.shade600
      ..style = PaintingStyle.fill;

    final currentPointPaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.fill;

    final previewLinePaint = Paint()
      ..color = Colors.green.shade700
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const textStyle = TextStyle(
      color: Colors.black87,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    );

    if (mappedRecordedPoints.length >= 2) {
      final path = Path()
        ..moveTo(mappedRecordedPoints.first.dx, mappedRecordedPoints.first.dy);

      for (int i = 1; i < mappedRecordedPoints.length; i++) {
        path.lineTo(mappedRecordedPoints[i].dx, mappedRecordedPoints[i].dy);
      }

      if (mappedRecordedPoints.length >= PlotGeometry.requiredPointCount) {
        path.close();
        canvas.drawPath(path, fillPaint);
      }

      canvas.drawPath(path, linePaint);
    }

    for (int i = 0; i < mappedRecordedPoints.length; i++) {
      final point = mappedRecordedPoints[i];
      canvas.drawCircle(point, 10, recordedPointPaint);

      final textPainter = TextPainter(
        text: TextSpan(text: '${i + 1}', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, point + const Offset(14, -22));
    }

    if (currentPosition != null && mappedPreviewPoints.isNotEmpty) {
      final currentPreviewPoint = mappedPreviewPoints.last;

      if (mappedRecordedPoints.isNotEmpty) {
        _drawDashedLine(
          canvas,
          mappedRecordedPoints.last,
          currentPreviewPoint,
          previewLinePaint,
        );
      }

      canvas.drawCircle(currentPreviewPoint, 12, currentPointPaint);

      final previewTextPainter = TextPainter(
        text: TextSpan(
          text: 'CURRENT',
          style: textStyle.copyWith(
            color: Colors.green.shade800,
            fontSize: 20,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      previewTextPainter.paint(
        canvas,
        currentPreviewPoint + const Offset(20, -34),
      );
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    const dashWidth = 12.0;
    const dashSpace = 8.0;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    if (distance == 0) return;

    final unitX = dx / distance;
    final unitY = dy / distance;
    double currentDistance = 0;

    while (currentDistance < distance) {
      final x1 = start.dx + unitX * currentDistance;
      final y1 = start.dy + unitY * currentDistance;
      final nextDistance = math.min(currentDistance + dashWidth, distance);
      final x2 = start.dx + unitX * nextDistance;
      final y2 = start.dy + unitY * nextDistance;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant PlotPreviewPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.currentPosition != currentPosition;
  }
}
