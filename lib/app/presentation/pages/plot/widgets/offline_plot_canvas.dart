import 'dart:math' as math;

import 'package:digital_shores/app/presentation/pages/plot/map/plot_map_mode.dart';
import 'package:digital_shores/app/presentation/pages/plot/models/plot_point.dart';
import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:digital_shores/app/presentation/pages/plot/utils/plot_geometry.dart';
import 'package:flutter/material.dart';

class OfflinePlotCanvas extends StatefulWidget {
  const OfflinePlotCanvas({
    super.key,
    required this.savedPlots,
    required this.draftPoints,
    required this.mode,
    required this.selectedPlotId,
    required this.onPlotSelected,
  });

  final List<SavedPlot> savedPlots;
  final List<PlotPoint> draftPoints;
  final PlotMapMode mode;
  final String? selectedPlotId;
  final ValueChanged<SavedPlot?> onPlotSelected;

  @override
  State<OfflinePlotCanvas> createState() => _OfflinePlotCanvasState();
}

class _OfflinePlotCanvasState extends State<OfflinePlotCanvas> {
  final TransformationController _controller = TransformationController();
  Size _viewportSize = Size.zero;
  bool _hasUserMoved = false;
  bool _hasFitInitialView = false;
  bool _isProgrammaticMove = false;
  double _currentScale = 1.0;
  int _lastFocusedDraftPointCount = -1;
  String? _lastFocusedSelectedPlotId;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTransformChanged);
  }

  @override
  void didUpdateWidget(covariant OfflinePlotCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldRefreshView()) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resetView());
    }
  }

  bool _shouldRefreshView() {
    if (widget.mode == PlotMapMode.recording) {
      return widget.draftPoints.length != _lastFocusedDraftPointCount;
    }

    if (widget.mode == PlotMapMode.overview) {
      return widget.selectedPlotId != _lastFocusedSelectedPlotId;
    }

    return false;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTransformChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleTransformChanged() {
    final scale = _controller.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() < 0.001) {
      return;
    }
    setState(() {
      _currentScale = scale;
    });
  }

  void _resetView() {
    if (!mounted || _viewportSize == Size.zero) {
      return;
    }

    final layout = OfflinePlotCanvasLayout.build(
      savedPlots: widget.savedPlots,
      draftPoints: widget.draftPoints,
      mode: widget.mode,
    );
    final rect = _preferredFocusRect(layout);
    if (rect == null) {
      return;
    }

    final padding = _focusPadding;
    final availableWidth = math.max(_viewportSize.width - padding * 2, 1.0);
    final availableHeight = math.max(_viewportSize.height - padding * 2, 1.0);
    final horizontalScale = availableWidth / rect.width;
    final verticalScale = availableHeight / rect.height;
    final targetScale =
        math.min(horizontalScale, verticalScale).clamp(0.05, 20.0).toDouble();
    final dx = (_viewportSize.width / 2) - (rect.center.dx * targetScale);
    final dy = (_viewportSize.height / 2) - (rect.center.dy * targetScale);

    _isProgrammaticMove = true;
    _controller.value = Matrix4.identity()
      ..storage[0] = targetScale
      ..storage[5] = targetScale
      ..storage[12] = dx
      ..storage[13] = dy;
    _currentScale = targetScale;
    _hasUserMoved = false;
    _hasFitInitialView = true;
    _lastFocusedDraftPointCount = widget.draftPoints.length;
    _lastFocusedSelectedPlotId = widget.selectedPlotId;
    _isProgrammaticMove = false;
  }

  double get _focusPadding {
    if (_viewportSize == Size.zero) {
      return 44;
    }
    return (_viewportSize.shortestSide * 0.14).clamp(32.0, 72.0).toDouble();
  }

  Rect? _preferredFocusRect(OfflinePlotCanvasLayout layout) {
    if (widget.mode == PlotMapMode.recording && layout.draftBounds != null) {
      return layout.draftBounds;
    }
    if (widget.selectedPlotId != null) {
      for (final item in layout.savedItems) {
        if (item.plot.id == widget.selectedPlotId) {
          return item.bounds;
        }
      }
    }
    return layout.allBounds;
  }

  @override
  Widget build(BuildContext context) {
    final layout = OfflinePlotCanvasLayout.build(
      savedPlots: widget.savedPlots,
      draftPoints: widget.draftPoints,
      mode: widget.mode,
    );

    if (!layout.hasContent) {
      return const Center(child: Text('Tidak ada pratinjau'));
    }

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_hasUserMoved && !_hasFitInitialView) {
                _resetView();
              }
            });

            return GestureDetector(
              onScaleStart: (_) {
                if (!_isProgrammaticMove) {
                  _hasUserMoved = true;
                }
              },
              child: InteractiveViewer(
                transformationController: _controller,
                constrained: false,
                minScale: 0.05,
                maxScale: 20.0,
                boundaryMargin: const EdgeInsets.all(240),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    for (final item in layout.savedItems.reversed) {
                      if (item.path.contains(details.localPosition)) {
                        widget.onPlotSelected(item.plot);
                        return;
                      }
                    }
                    widget.onPlotSelected(null);
                  },
                  child: CustomPaint(
                    size: OfflinePlotCanvasLayout.canvasSize,
                    painter: OfflinePlotCanvasPainter(
                      layout: layout,
                      selectedPlotId: widget.selectedPlotId,
                      viewportScale: _currentScale,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.mode == PlotMapMode.recording)
          Positioned(
            right: 8,
            top: 8,
            child: Material(
              color: Colors.white.withValues(alpha: 0.92),
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Reset tampilan',
                icon: const Icon(Icons.my_location),
                onPressed: _resetView,
              ),
            ),
          ),
      ],
    );
  }
}

class OfflinePlotCanvasItem {
  const OfflinePlotCanvasItem({
    required this.index,
    required this.plot,
    required this.path,
    required this.center,
    required this.bounds,
  });

  final int index;
  final SavedPlot plot;
  final Path path;
  final Offset center;
  final Rect bounds;
}

class OfflinePlotCanvasLayout {
  const OfflinePlotCanvasLayout({
    required this.savedItems,
    required this.draftPath,
    required this.draftOffsets,
    required this.draftBounds,
    required this.allBounds,
  });

  static const Size canvasSize = Size(1400, 1400);
  static const double padding = 120;

  final List<OfflinePlotCanvasItem> savedItems;
  final Path? draftPath;
  final List<Offset> draftOffsets;
  final Rect? draftBounds;
  final Rect? allBounds;

  bool get hasContent => allBounds != null;

  static OfflinePlotCanvasLayout build({
    required List<SavedPlot> savedPlots,
    required List<PlotPoint> draftPoints,
    required PlotMapMode mode,
  }) {
    final allPoints = <PlotPoint>[
      for (final plot in savedPlots) ...plot.points,
      ...draftPoints,
    ];

    if (allPoints.isEmpty) {
      return const OfflinePlotCanvasLayout(
        savedItems: <OfflinePlotCanvasItem>[],
        draftPath: null,
        draftOffsets: <Offset>[],
        draftBounds: null,
        allBounds: null,
      );
    }

    final referencePoints =
        mode == PlotMapMode.recording && draftPoints.isNotEmpty
            ? draftPoints
            : allPoints;
    final mapper = _CanvasPointMapper(referencePoints);
    final savedItems = savedPlots.asMap().entries.where((entry) {
      return entry.value.points.isNotEmpty;
    }).map((entry) {
      final offsets = entry.value.points.map(mapper.map).toList();
      final path = _pathFromOffsets(offsets, close: true);
      return OfflinePlotCanvasItem(
        index: entry.key,
        plot: entry.value,
        path: path,
        center: _centerOf(offsets),
        bounds: _boundsOf(offsets),
      );
    }).toList();

    final draftOffsets = draftPoints.map(mapper.map).toList();
    final draftPath = draftOffsets.length >= 2
        ? _pathFromOffsets(
            draftOffsets,
            close: draftOffsets.length >= PlotGeometry.requiredPointCount,
          )
        : null;

    return OfflinePlotCanvasLayout(
      savedItems: savedItems,
      draftPath: draftPath,
      draftOffsets: draftOffsets,
      draftBounds: draftOffsets.isEmpty ? null : _boundsOf(draftOffsets),
      allBounds: _boundsOf(<Offset>[
        for (final item in savedItems) ..._pathApproximation(item.path),
        ...draftOffsets,
      ]),
    );
  }

  static Path _pathFromOffsets(List<Offset> offsets, {required bool close}) {
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (var i = 1; i < offsets.length; i++) {
      path.lineTo(offsets[i].dx, offsets[i].dy);
    }
    if (close) {
      path.close();
    }
    return path;
  }

  static List<Offset> _pathApproximation(Path path) {
    final bounds = path.getBounds();
    return <Offset>[
      bounds.topLeft,
      bounds.topRight,
      bounds.bottomLeft,
      bounds.bottomRight
    ];
  }

  static Offset _centerOf(List<Offset> offsets) {
    final dx = offsets.fold<double>(0, (sum, offset) => sum + offset.dx);
    final dy = offsets.fold<double>(0, (sum, offset) => sum + offset.dy);
    return Offset(dx / offsets.length, dy / offsets.length);
  }

  static Rect _boundsOf(List<Offset> offsets) {
    final minX = offsets.map((offset) => offset.dx).reduce(math.min);
    final maxX = offsets.map((offset) => offset.dx).reduce(math.max);
    final minY = offsets.map((offset) => offset.dy).reduce(math.min);
    final maxY = offsets.map((offset) => offset.dy).reduce(math.max);
    const minimumSpan = 80.0;
    final widthPadding = math.max((maxX - minX) * 0.2, minimumSpan);
    final heightPadding = math.max((maxY - minY) * 0.2, minimumSpan);

    return Rect.fromLTRB(
      minX - widthPadding,
      minY - heightPadding,
      maxX + widthPadding,
      maxY + heightPadding,
    );
  }
}

class _CanvasPointMapper {
  _CanvasPointMapper(List<PlotPoint> points)
      : this._(
          _expandRange(
            points.map((point) => point.latitude).reduce(math.min),
            points.map((point) => point.latitude).reduce(math.max),
          ),
          _expandRange(
            points.map((point) => point.longitude).reduce(math.min),
            points.map((point) => point.longitude).reduce(math.max),
          ),
        );

  _CanvasPointMapper._(
    _ExpandedCoordinateRange latitudeRange,
    _ExpandedCoordinateRange longitudeRange,
  )   : minLatitude = latitudeRange.min,
        maxLatitude = latitudeRange.max,
        minLongitude = longitudeRange.min,
        maxLongitude = longitudeRange.max;

  final double minLatitude;
  final double maxLatitude;
  final double minLongitude;
  final double maxLongitude;

  static _ExpandedCoordinateRange _expandRange(
    double minValue,
    double maxValue,
  ) {
    if (minValue != maxValue) {
      return _ExpandedCoordinateRange(minValue, maxValue);
    }

    const halfSpan = 0.00005;
    return _ExpandedCoordinateRange(minValue - halfSpan, maxValue + halfSpan);
  }

  Offset map(PlotPoint point) {
    final latitudeRange = maxLatitude - minLatitude;
    final longitudeRange = maxLongitude - minLongitude;

    final usableWidth = OfflinePlotCanvasLayout.canvasSize.width -
        OfflinePlotCanvasLayout.padding * 2;
    final usableHeight = OfflinePlotCanvasLayout.canvasSize.height -
        OfflinePlotCanvasLayout.padding * 2;
    final scale = math.min(
      usableWidth / longitudeRange,
      usableHeight / latitudeRange,
    );
    final contentWidth = longitudeRange * scale;
    final contentHeight = latitudeRange * scale;
    final offsetX =
        (OfflinePlotCanvasLayout.canvasSize.width - contentWidth) / 2;
    final offsetY =
        (OfflinePlotCanvasLayout.canvasSize.height - contentHeight) / 2;

    return Offset(
      offsetX + (point.longitude - minLongitude) * scale,
      OfflinePlotCanvasLayout.canvasSize.height -
          offsetY -
          (point.latitude - minLatitude) * scale,
    );
  }
}

class _ExpandedCoordinateRange {
  const _ExpandedCoordinateRange(this.min, this.max);

  final double min;
  final double max;
}

class OfflinePlotCanvasPainter extends CustomPainter {
  const OfflinePlotCanvasPainter({
    required this.layout,
    required this.selectedPlotId,
    required this.viewportScale,
  });

  final OfflinePlotCanvasLayout layout;
  final String? selectedPlotId;
  final double viewportScale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += 100) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (final item in layout.savedItems) {
      final isSelected = item.plot.id == selectedPlotId;
      final strokeColor =
          item.plot.isSynced ? Colors.green.shade800 : Colors.orange.shade800;
      final fillColor = item.plot.isSynced
          ? Colors.green.withValues(alpha: isSelected ? 0.38 : 0.24)
          : Colors.orange.withValues(alpha: isSelected ? 0.42 : 0.26);

      canvas.drawPath(
        item.path,
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        item.path,
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = (isSelected ? 3.2 : 2.2) / _normalizedScale,
      );

      if (isSelected) {
        _drawBadge(canvas, item.center, '${item.index + 1}', strokeColor);
      }
    }

    if (layout.draftPath != null) {
      canvas.drawPath(
        layout.draftPath!,
        Paint()
          ..color = Colors.blue.withValues(alpha: 0.22)
          ..style =
              layout.draftOffsets.length >= PlotGeometry.requiredPointCount
                  ? PaintingStyle.fill
                  : PaintingStyle.stroke
          ..strokeWidth = 3 / _normalizedScale,
      );
      canvas.drawPath(
        layout.draftPath!,
        Paint()
          ..color = Colors.blue.shade800
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 / _normalizedScale,
      );
    }

    for (var i = 0; i < layout.draftOffsets.length; i++) {
      _drawBadge(
          canvas, layout.draftOffsets[i], '${i + 1}', Colors.blue.shade800);
    }
  }

  double get _normalizedScale => viewportScale <= 0 ? 1 : viewportScale;

  void _drawBadge(Canvas canvas, Offset center, String text, Color color) {
    final radius = 14 / _normalizedScale;
    final fontSize = 12 / _normalizedScale;
    canvas.drawCircle(center, radius, Paint()..color = color);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant OfflinePlotCanvasPainter oldDelegate) {
    return oldDelegate.layout != layout ||
        oldDelegate.selectedPlotId != selectedPlotId ||
        oldDelegate.viewportScale != viewportScale;
  }
}
