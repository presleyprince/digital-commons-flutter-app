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
    this.resetSignal = 0,
  });

  final List<SavedPlot> savedPlots;
  final List<PlotPoint> draftPoints;
  final PlotMapMode mode;
  final String? selectedPlotId;
  final ValueChanged<SavedPlot?> onPlotSelected;
  final int resetSignal;

  @override
  State<OfflinePlotCanvas> createState() => _OfflinePlotCanvasState();
}

class _OfflinePlotCanvasState extends State<OfflinePlotCanvas> {
  final TransformationController _controller = TransformationController();
  Size _viewportSize = Size.zero;
  bool _hasUserMoved = false;
  bool _hasFitInitialView = false;
  bool _isProgrammaticMove = false;
  bool _isClampingTransform = false;
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
    if (widget.resetSignal != oldWidget.resetSignal) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _resetView(showOverview: true),
      );
    }
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
    if (!_isProgrammaticMove && !_isClampingTransform) {
      _clampTransform();
    }
    // Panning must also repaint the visible grid at large zoom levels.
    setState(() {
      _currentScale = _controller.value.getMaxScaleOnAxis();
    });
  }

  void _resetView({bool showOverview = false}) {
    if (!mounted || _viewportSize == Size.zero) {
      return;
    }

    final layout = OfflinePlotCanvasLayout.build(
      savedPlots: widget.savedPlots,
      draftPoints: widget.draftPoints,
      mode: widget.mode,
      viewportSize: _viewportSize,
    );
    final rect = showOverview
        ? layout.allBounds ?? _preferredFocusRect(layout)
        : _preferredFocusRect(layout);
    if (rect == null) {
      return;
    }

    final padding = _focusPadding;
    final availableWidth = math.max(_viewportSize.width - padding * 2, 1.0);
    final availableHeight = math.max(_viewportSize.height - padding * 2, 1.0);
    final horizontalScale = availableWidth / rect.width;
    final verticalScale = availableHeight / rect.height;
    final minScale = _minimumZoomScale(layout);
    final maxScale = _maximumZoomScale(layout);
    final targetScale = showOverview
        ? minScale
        : math
            .min(horizontalScale, verticalScale)
            .clamp(minScale, maxScale)
            .toDouble();
    final dx = (_viewportSize.width / 2) - (rect.center.dx * targetScale);
    final dy = (_viewportSize.height / 2) - (rect.center.dy * targetScale);

    _isProgrammaticMove = true;
    final matrix = Matrix4.identity()
      ..storage[0] = targetScale
      ..storage[5] = targetScale
      // Keep all axes consistent with getMaxScaleOnAxis, including below 1x.
      ..storage[10] = targetScale
      ..storage[12] = dx
      ..storage[13] = dy;
    _controller.value = _clampedMatrix(matrix, layout);
    _currentScale = targetScale;
    _hasUserMoved = false;
    _hasFitInitialView = true;
    _lastFocusedDraftPointCount = widget.draftPoints.length;
    _lastFocusedSelectedPlotId = widget.selectedPlotId;
    _isProgrammaticMove = false;
  }

  void _clampTransform() {
    if (_viewportSize == Size.zero) {
      return;
    }

    final layout = OfflinePlotCanvasLayout.build(
      savedPlots: widget.savedPlots,
      draftPoints: widget.draftPoints,
      mode: widget.mode,
      viewportSize: _viewportSize,
    );
    final current = _controller.value;
    final clamped = _clampedMatrix(current, layout);
    if ((current.storage[12] - clamped.storage[12]).abs() < 0.001 &&
        (current.storage[13] - clamped.storage[13]).abs() < 0.001 &&
        (current.getMaxScaleOnAxis() - clamped.getMaxScaleOnAxis()).abs() <
            0.000001) {
      return;
    }

    _isClampingTransform = true;
    _controller.value = clamped;
    _isClampingTransform = false;
  }

  Matrix4 _clampedMatrix(Matrix4 source, OfflinePlotCanvasLayout layout) {
    final scale = source
        .getMaxScaleOnAxis()
        .clamp(_minimumZoomScale(layout), _maximumZoomScale(layout))
        .toDouble();
    final scaledWidth = layout.canvasSize.width * scale;
    final scaledHeight = layout.canvasSize.height * scale;
    final matrix = source.clone();

    matrix.storage[0] = scale;
    matrix.storage[5] = scale;
    matrix.storage[10] = scale;
    matrix.storage[12] = _clampedTranslation(
      value: matrix.storage[12],
      viewportExtent: _viewportSize.width,
      scaledContentExtent: scaledWidth,
    );
    matrix.storage[13] = _clampedTranslation(
      value: matrix.storage[13],
      viewportExtent: _viewportSize.height,
      scaledContentExtent: scaledHeight,
    );
    return matrix;
  }

  double _clampedTranslation({
    required double value,
    required double viewportExtent,
    required double scaledContentExtent,
  }) {
    if (scaledContentExtent <= viewportExtent) {
      return (viewportExtent - scaledContentExtent) / 2;
    }

    final minTranslation = viewportExtent - scaledContentExtent;
    return value.clamp(minTranslation, 0.0).toDouble();
  }

  double get _focusPadding {
    if (_viewportSize == Size.zero) {
      return 44;
    }
    return (_viewportSize.shortestSide * 0.14).clamp(32.0, 72.0).toDouble();
  }

  Rect? _preferredFocusRect(OfflinePlotCanvasLayout layout) {
    if (widget.mode == PlotMapMode.recording && layout.draftBounds != null) {
      return _draftFocusRect(layout);
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

  Rect _draftFocusRect(OfflinePlotCanvasLayout layout) {
    final bounds = layout.draftBounds!;
    // A point or an axis-aligned line still needs finite fit dimensions.
    // Use screen space at the existing hard zoom limit, not global canvas padding.
    return Rect.fromCenter(
      center: bounds.center,
      width: math.max(
          bounds.width, (_viewportSize.width - _focusPadding * 2) / 20),
      height: math.max(
          bounds.height, (_viewportSize.height - _focusPadding * 2) / 20),
    );
  }

  double _minimumZoomScale(OfflinePlotCanvasLayout layout) {
    final rect = layout.allBounds ?? (Offset.zero & layout.canvasSize);
    return _scaleToFit(rect, layout, minimum: 0.05, maximum: 20.0);
  }

  double _maximumZoomScale(OfflinePlotCanvasLayout layout) {
    if (widget.mode == PlotMapMode.overview &&
        layout.shortestSavedEdgeLength != null) {
      // At maximum zoom, three shortest edges fit across the usable short side.
      const visibleShortestEdges = 3.0;
      final available =
          math.max(_viewportSize.shortestSide - _focusPadding * 2, 1.0);
      return math.max(_minimumZoomScale(layout),
          available / (layout.shortestSavedEdgeLength! * visibleShortestEdges));
    }
    final smallestBounds = layout.smallestPlotBounds;
    if (smallestBounds == null) {
      return 20.0;
    }
    final scale =
        _scaleToFit(smallestBounds, layout, minimum: 0.05, maximum: 20.0);
    final savedMaximum = math.max(scale, _minimumZoomScale(layout));
    if (widget.mode == PlotMapMode.recording && layout.draftBounds != null) {
      return math.max(
          savedMaximum,
          _scaleToFit(_draftFocusRect(layout), layout,
              minimum: 0.05, maximum: 20.0));
    }
    return savedMaximum;
  }

  double _scaleToFit(
    Rect rect,
    OfflinePlotCanvasLayout layout, {
    required double minimum,
    required double maximum,
  }) {
    if (_viewportSize == Size.zero || rect.width <= 0 || rect.height <= 0) {
      return minimum;
    }

    final padding = _focusPadding;
    final availableWidth = math.max(_viewportSize.width - padding * 2, 1.0);
    final availableHeight = math.max(_viewportSize.height - padding * 2, 1.0);
    final horizontalScale = availableWidth / rect.width;
    final verticalScale = availableHeight / rect.height;
    final canvasFillScale = math.max(
      _viewportSize.width / layout.canvasSize.width,
      _viewportSize.height / layout.canvasSize.height,
    );
    return math
        .max(math.min(horizontalScale, verticalScale), canvasFillScale)
        .clamp(minimum, maximum)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        final layout = OfflinePlotCanvasLayout.build(
          savedPlots: widget.savedPlots,
          draftPoints: widget.draftPoints,
          mode: widget.mode,
          viewportSize: _viewportSize,
        );
        final minScale = _minimumZoomScale(layout);
        final maxScale = _maximumZoomScale(layout);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (layout.hasContent && !_hasUserMoved && !_hasFitInitialView) {
            _resetView(
              showOverview: widget.mode != PlotMapMode.recording ||
                  widget.draftPoints.isEmpty,
            );
            return;
          }
          _clampTransform();
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
            minScale: minScale,
            maxScale: maxScale,
            boundaryMargin: EdgeInsets.zero,
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
                size: layout.canvasSize,
                painter: OfflinePlotCanvasPainter(
                  layout: layout,
                  selectedPlotId: widget.selectedPlotId,
                  viewportScale: _currentScale,
                  visibleBounds: MatrixUtils.transformRect(
                    Matrix4.inverted(_controller.value),
                    Offset.zero & _viewportSize,
                  ),
                ),
                child: layout.hasContent
                    ? null
                    : SizedBox(
                        width: layout.canvasSize.width,
                        height: layout.canvasSize.height,
                        child: Center(child: Text('Tidak ada pratinjau')),
                      ),
              ),
            ),
          ),
        );
      },
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
    this.shortestEdgeLength,
  });

  final int index;
  final SavedPlot plot;
  final Path path;
  final Offset center;
  final Rect bounds;
  final double? shortestEdgeLength;
}

class OfflinePlotCanvasLayout {
  const OfflinePlotCanvasLayout({
    required this.canvasSize,
    required this.savedItems,
    required this.draftPath,
    required this.draftOffsets,
    required this.draftBounds,
    required this.allBounds,
    required this.smallestPlotBounds,
  });

  static const double baseCanvasWidth = 4200;
  static const double minimumCanvasHeight = 4200;

  final Size canvasSize;

  final List<OfflinePlotCanvasItem> savedItems;
  final Path? draftPath;
  final List<Offset> draftOffsets;
  final Rect? draftBounds;
  final Rect? allBounds;
  final Rect? smallestPlotBounds;

  double get padding => canvasSize.shortestSide * 0.12;

  bool get hasContent => allBounds != null;

  double? get shortestSavedEdgeLength {
    double? shortest;
    for (final item in savedItems) {
      final length = item.shortestEdgeLength;
      if (length != null && (shortest == null || length < shortest)) {
        shortest = length;
      }
    }
    return shortest;
  }

  static OfflinePlotCanvasLayout build({
    required List<SavedPlot> savedPlots,
    required List<PlotPoint> draftPoints,
    required PlotMapMode mode,
    required Size viewportSize,
  }) {
    final canvasSize = _canvasSizeForViewport(viewportSize);
    final allPoints = <PlotPoint>[
      for (final plot in savedPlots) ...plot.points,
      ...draftPoints,
    ];

    if (allPoints.isEmpty) {
      return OfflinePlotCanvasLayout(
        canvasSize: canvasSize,
        savedItems: <OfflinePlotCanvasItem>[],
        draftPath: null,
        draftOffsets: <Offset>[],
        draftBounds: null,
        allBounds: null,
        smallestPlotBounds: null,
      );
    }

    final mapper = _CanvasPointMapper(
      allPoints,
      canvasSize: canvasSize,
      padding: canvasSize.shortestSide * 0.12,
    );
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
        shortestEdgeLength: _shortestEdgeLength(offsets),
      );
    }).toList();

    final draftOffsets = draftPoints.map(mapper.map).toList();
    final draftPath = draftOffsets.length >= 2
        ? _pathFromOffsets(
            draftOffsets,
            close: draftOffsets.length >= PlotGeometry.requiredPointCount,
          )
        : null;

    final smallestPlotBounds = _smallestPlotBounds(savedItems);

    return OfflinePlotCanvasLayout(
      canvasSize: canvasSize,
      savedItems: savedItems,
      draftPath: draftPath,
      draftOffsets: draftOffsets,
      draftBounds:
          draftOffsets.isEmpty ? null : _draftBoundsOf(draftOffsets, mapper),
      allBounds: _boundsOf(<Offset>[
        for (final item in savedItems) ..._pathApproximation(item.path),
        ...draftOffsets,
      ]),
      smallestPlotBounds: smallestPlotBounds,
    );
  }

  static Size _canvasSizeForViewport(Size viewportSize) {
    if (viewportSize.width <= 0 || viewportSize.height <= 0) {
      return const Size(baseCanvasWidth, minimumCanvasHeight);
    }

    final viewportAspect = viewportSize.width / viewportSize.height;
    final canvasHeight = math.max(
      baseCanvasWidth / viewportAspect,
      minimumCanvasHeight,
    );
    return Size(baseCanvasWidth, canvasHeight);
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
      bounds.bottomRight,
    ];
  }

  static Offset _centerOf(List<Offset> offsets) {
    final dx = offsets.fold<double>(0, (sum, offset) => sum + offset.dx);
    final dy = offsets.fold<double>(0, (sum, offset) => sum + offset.dy);
    return Offset(dx / offsets.length, dy / offsets.length);
  }

  static Rect? _smallestPlotBounds(List<OfflinePlotCanvasItem> savedItems) {
    Rect? smallestBounds;
    double? smallestArea;
    for (final item in savedItems) {
      final area = item.bounds.width * item.bounds.height;
      if (smallestArea == null || area < smallestArea) {
        smallestArea = area;
        smallestBounds = item.bounds;
      }
    }
    return smallestBounds;
  }

  static double? _shortestEdgeLength(List<Offset> offsets) {
    if (offsets.length < PlotGeometry.requiredPointCount) return null;
    double? shortest;
    for (var i = 0; i < offsets.length; i++) {
      final length = (offsets[(i + 1) % offsets.length] - offsets[i]).distance;
      // Ignore duplicate vertices and numerically degenerate edges.
      if (length.isFinite &&
          length > 1e-6 &&
          (shortest == null || length < shortest)) {
        shortest = length;
      }
    }
    return shortest;
  }

  static Rect _boundsOf(List<Offset> offsets) {
    final minX = offsets.map((offset) => offset.dx).reduce(math.min);
    final maxX = offsets.map((offset) => offset.dx).reduce(math.max);
    final minY = offsets.map((offset) => offset.dy).reduce(math.min);
    final maxY = offsets.map((offset) => offset.dy).reduce(math.max);
    const minimumSpan = 240.0;
    final widthPadding = math.max((maxX - minX) * 0.2, minimumSpan);
    final heightPadding = math.max((maxY - minY) * 0.2, minimumSpan);

    return Rect.fromLTRB(
      minX - widthPadding,
      minY - heightPadding,
      maxX + widthPadding,
      maxY + heightPadding,
    );
  }

  static Rect _draftBoundsOf(List<Offset> offsets, _CanvasPointMapper mapper) {
    final bounds = Rect.fromLTRB(
      offsets.map((p) => p.dx).reduce(math.min),
      offsets.map((p) => p.dy).reduce(math.min),
      offsets.map((p) => p.dx).reduce(math.max),
      offsets.map((p) => p.dy).reduce(math.max),
    );
    if (bounds.width == 0 && bounds.height == 0) {
      // About 33 metres in latitude: a useful near view for the first GPS fix
      // (or coincident fixes), independent of how far saved plots are spread.
      final span = mapper.unitsPerDegree * 0.0003;
      return Rect.fromCenter(center: bounds.center, width: span, height: span);
    }
    return bounds;
  }
}

class _CanvasPointMapper {
  _CanvasPointMapper(
    List<PlotPoint> points, {
    required Size canvasSize,
    required double padding,
  }) : this._(
          _expandRange(
            points.map((point) => point.latitude).reduce(math.min),
            points.map((point) => point.latitude).reduce(math.max),
          ),
          _expandRange(
            points.map((point) => point.longitude).reduce(math.min),
            points.map((point) => point.longitude).reduce(math.max),
          ),
          canvasSize,
          padding,
        );

  _CanvasPointMapper._(
    _ExpandedCoordinateRange latitudeRange,
    _ExpandedCoordinateRange longitudeRange,
    this.canvasSize,
    this.padding,
  )   : minLatitude = latitudeRange.min,
        maxLatitude = latitudeRange.max,
        minLongitude = longitudeRange.min,
        maxLongitude = longitudeRange.max;

  final double minLatitude;
  final double maxLatitude;
  final double minLongitude;
  final double maxLongitude;
  final Size canvasSize;
  final double padding;

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

  double get unitsPerDegree => math.min(
        (canvasSize.width - padding * 2) / (maxLongitude - minLongitude),
        (canvasSize.height - padding * 2) / (maxLatitude - minLatitude),
      );

  Offset map(PlotPoint point) {
    final latitudeRange = maxLatitude - minLatitude;
    final longitudeRange = maxLongitude - minLongitude;

    final scale = unitsPerDegree;
    final contentWidth = longitudeRange * scale;
    final contentHeight = latitudeRange * scale;
    final offsetX = (canvasSize.width - contentWidth) / 2;
    final offsetY = (canvasSize.height - contentHeight) / 2;

    return Offset(
      offsetX + (point.longitude - minLongitude) * scale,
      canvasSize.height - offsetY - (point.latitude - minLatitude) * scale,
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
    this.visibleBounds,
  });

  final OfflinePlotCanvasLayout layout;
  final String? selectedPlotId;
  final double viewportScale;
  final Rect? visibleBounds;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

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

  void _drawGrid(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    final minorGridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1 / _normalizedScale;
    final majorGridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1 / _normalizedScale;

    final minorStep = _niceGridStep(34 / _normalizedScale);
    final majorStep = minorStep * 5;
    final visible = (visibleBounds ?? (Offset.zero & size))
        .inflate(minorStep)
        .intersect(Offset.zero & size);
    if (visible.isEmpty) return;

    for (double x = (visible.left / minorStep).floor() * minorStep;
        x <= visible.right;
        x += minorStep) {
      final paint =
          _isMajorGridLine(x, majorStep) ? majorGridPaint : minorGridPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = (visible.top / minorStep).floor() * minorStep;
        y <= visible.bottom;
        y += minorStep) {
      final paint =
          _isMajorGridLine(y, majorStep) ? majorGridPaint : minorGridPaint;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  double _niceGridStep(double rawStep) {
    if (rawStep <= 0) {
      return 50;
    }

    final exponent = math.pow(
      10,
      (math.log(rawStep) / math.ln10).floor(),
    );
    final normalized = rawStep / exponent;
    final niceMultiplier = normalized <= 1
        ? 1
        : normalized <= 2
            ? 2
            : normalized <= 5
                ? 5
                : 10;
    return niceMultiplier * exponent.toDouble();
  }

  bool _isMajorGridLine(double value, double majorStep) {
    if (majorStep <= 0) {
      return false;
    }
    final nearest = (value / majorStep).round() * majorStep;
    return (value - nearest).abs() < 0.001;
  }

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
        oldDelegate.viewportScale != viewportScale ||
        oldDelegate.visibleBounds != visibleBounds;
  }
}
