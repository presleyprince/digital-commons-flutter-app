import 'package:digital_shores/app/presentation/pages/plot/utils/plot_overview_layout.dart';
import 'package:flutter/material.dart';

class PlotOverviewPainter extends CustomPainter {
  PlotOverviewPainter({
    required this.items,
    required this.selectedPlotId,
    required this.viewportScale,
  });

  final List<PlotOverviewItem> items;
  final String? selectedPlotId;
  final double viewportScale;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += 100) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (final item in items) {
      final isSelected = item.plot.id == selectedPlotId;
      final fillColor = item.plot.isSynced
          ? Colors.green.withValues(alpha: isSelected ? 0.38 : 0.26)
          : Colors.orange.withValues(alpha: isSelected ? 0.42 : 0.28);
      final strokeColor = item.plot.isSynced
          ? Colors.green.shade800
          : Colors.orange.shade800;

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 6 : 4;

      final normalizedScale = viewportScale <= 0 ? 1.0 : viewportScale;
      final targetScreenRadius = isSelected ? 16.0 : 13.0;
      final targetScreenFontSize = isSelected ? 14.0 : 12.0;
      final badgeRadius = targetScreenRadius / normalizedScale;
      final fontSize = targetScreenFontSize / normalizedScale;
      final badgeStrokeWidth = (isSelected ? 2.6 : 2.1) / normalizedScale;

      canvas.drawPath(item.path, fillPaint);
      canvas.drawPath(
        item.path,
        strokePaint..strokeWidth = badgeStrokeWidth,
      );

      if (!isSelected) {
        continue;
      }

      canvas.drawCircle(
        item.center,
        badgeRadius,
        Paint()..color = strokeColor,
      );

      final numberPainter = TextPainter(
        text: TextSpan(
          text: '${item.index + 1}',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      final numberOffset = Offset(
        item.center.dx - numberPainter.width / 2,
        item.center.dy - numberPainter.height / 2,
      );
      numberPainter.paint(canvas, numberOffset);
    }
  }

  @override
  bool shouldRepaint(covariant PlotOverviewPainter oldDelegate) {
    return oldDelegate.items != items ||
        oldDelegate.selectedPlotId != selectedPlotId ||
        oldDelegate.viewportScale != viewportScale;
  }
}
