import 'package:digital_shores/app/presentation/pages/plot/map/plot_map_bounds.dart';
import 'package:digital_shores/app/presentation/pages/plot/map/plot_map_mode.dart';
import 'package:digital_shores/app/presentation/pages/plot/models/plot_point.dart';
import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:digital_shores/app/presentation/pages/plot/utils/plot_geometry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GooglePlotMap extends StatefulWidget {
  const GooglePlotMap({
    super.key,
    required this.savedPlots,
    required this.draftPoints,
    required this.mode,
    required this.selectedPlotId,
    required this.onPlotSelected,
    this.onMapReady,
  });

  final List<SavedPlot> savedPlots;
  final List<PlotPoint> draftPoints;
  final PlotMapMode mode;
  final String? selectedPlotId;
  final ValueChanged<SavedPlot?> onPlotSelected;
  final VoidCallback? onMapReady;

  @override
  State<GooglePlotMap> createState() => _GooglePlotMapState();
}

class _GooglePlotMapState extends State<GooglePlotMap> {
  GoogleMapController? _controller;
  Size _viewportSize = Size.zero;
  int _lastFocusedDraftPointCount = -1;
  String? _lastFocusedSelectedPlotId;

  @override
  void didUpdateWidget(covariant GooglePlotMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_shouldRefreshCamera()) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resetCamera());
    }
  }

  bool _shouldRefreshCamera() {
    if (widget.mode == PlotMapMode.recording) {
      return widget.draftPoints.length != _lastFocusedDraftPointCount;
    }

    if (widget.mode == PlotMapMode.overview) {
      return widget.selectedPlotId != _lastFocusedSelectedPlotId;
    }

    return false;
  }

  Future<void> _resetCamera() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    final cameraUpdate = _preferredCameraUpdate();
    if (cameraUpdate == null) {
      return;
    }

    await _moveCamera(cameraUpdate);
    _lastFocusedDraftPointCount = widget.draftPoints.length;
    _lastFocusedSelectedPlotId = widget.selectedPlotId;
  }

  CameraUpdate? _preferredCameraUpdate() {
    if (widget.mode == PlotMapMode.recording &&
        widget.draftPoints.length == 1) {
      return CameraUpdate.newLatLngZoom(
        _toLatLng(widget.draftPoints.first),
        19,
      );
    }

    final bounds = _preferredBounds();
    if (bounds == null) {
      return null;
    }

    return CameraUpdate.newLatLngBounds(
      bounds.toGoogleBounds(),
      _cameraPadding,
    );
  }

  double get _cameraPadding {
    if (_viewportSize == Size.zero) {
      return 44;
    }
    return (_viewportSize.shortestSide * 0.14).clamp(40.0, 88.0).toDouble();
  }

  Future<void> _moveCamera(CameraUpdate cameraUpdate) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    try {
      await controller.moveCamera(cameraUpdate);
    } catch (_) {
      // The native map may reject bounds updates before its viewport is ready.
    }
  }

  PlotMapBounds? _preferredBounds() {
    if (widget.mode == PlotMapMode.recording && widget.draftPoints.isNotEmpty) {
      return PlotMapBounds.fromPoints(widget.draftPoints);
    }

    if (widget.selectedPlotId != null) {
      for (final plot in widget.savedPlots) {
        if (plot.id == widget.selectedPlotId && plot.points.isNotEmpty) {
          return PlotMapBounds.fromPoints(plot.points);
        }
      }
    }

    final visiblePoints = collectVisiblePlotPoints(
      draftPoints: widget.draftPoints,
      savedPlotPoints: widget.savedPlots.map((plot) => plot.points),
    );
    if (visiblePoints.isEmpty) {
      return null;
    }
    return PlotMapBounds.fromPoints(visiblePoints);
  }

  Set<Polygon> _buildPolygons() {
    return <Polygon>{
      for (final entry in widget.savedPlots.asMap().entries)
        if (entry.value.points.length >= PlotGeometry.requiredPointCount)
          Polygon(
            polygonId: PolygonId(entry.value.id),
            points: entry.value.points.map(_toLatLng).toList(),
            fillColor: _fillColor(entry.value),
            strokeColor: _strokeColor(entry.value),
            strokeWidth: entry.value.id == widget.selectedPlotId ? 4 : 2,
            consumeTapEvents: true,
            onTap: () => widget.onPlotSelected(entry.value),
          ),
      if (widget.draftPoints.length >= PlotGeometry.requiredPointCount)
        Polygon(
          polygonId: const PolygonId('draft_plot'),
          points: widget.draftPoints.map(_toLatLng).toList(),
          fillColor: Colors.blue.withValues(alpha: 0.22),
          strokeColor: Colors.blue.shade800,
          strokeWidth: 3,
        ),
    };
  }

  Set<Polyline> _buildPolylines() {
    if (widget.draftPoints.length < 2) {
      return const <Polyline>{};
    }
    return <Polyline>{
      Polyline(
        polylineId: const PolylineId('draft_line'),
        points: widget.draftPoints.map(_toLatLng).toList(),
        color: Colors.blue.shade800,
        width: 4,
      ),
    };
  }

  Set<Marker> _buildMarkers() {
    return <Marker>{
      for (var i = 0; i < widget.draftPoints.length; i++)
        Marker(
          markerId: MarkerId('draft_$i'),
          position: _toLatLng(widget.draftPoints[i]),
          infoWindow: InfoWindow(title: 'Titik ${i + 1}'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      for (final entry in widget.savedPlots.asMap().entries)
        if (entry.value.points.isNotEmpty)
          Marker(
            markerId: MarkerId('saved_${entry.value.id}'),
            position: PlotMapBounds.fromPoints(entry.value.points).center,
            infoWindow: InfoWindow(
              title: '${entry.key + 1}. ${entry.value.name}',
              snippet: '${entry.value.areaSquareMeters.toStringAsFixed(2)} m2',
            ),
            visible: entry.value.id == widget.selectedPlotId,
          ),
    };
  }

  LatLng _toLatLng(PlotPoint point) {
    return LatLng(point.latitude, point.longitude);
  }

  Color _fillColor(SavedPlot plot) {
    if (plot.isSynced) {
      return Colors.green
          .withValues(alpha: plot.id == widget.selectedPlotId ? 0.38 : 0.24);
    }
    return Colors.orange
        .withValues(alpha: plot.id == widget.selectedPlotId ? 0.42 : 0.26);
  }

  Color _strokeColor(SavedPlot plot) {
    return plot.isSynced ? Colors.green.shade800 : Colors.orange.shade800;
  }

  @override
  Widget build(BuildContext context) {
    final preferredBounds = _preferredBounds();
    final initialTarget =
        preferredBounds?.center ?? const LatLng(-5.1477, 119.4327);

    return LayoutBuilder(
      builder: (context, constraints) {
        _viewportSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: initialTarget, zoom: 17),
              mapType: MapType.hybrid,
              markers: _buildMarkers(),
              polylines: _buildPolylines(),
              polygons: _buildPolygons(),
              buildingsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              zoomControlsEnabled: true,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
              },
              onMapCreated: (controller) {
                _controller = controller;
                widget.onMapReady?.call();
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _resetCamera());
              },
              onTap: (_) => widget.onPlotSelected(null),
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
                    onPressed: _resetCamera,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
