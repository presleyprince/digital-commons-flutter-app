import 'dart:async';

import 'package:digital_shores/app/presentation/pages/plot/map/plot_map_mode.dart';
import 'package:digital_shores/app/presentation/pages/plot/models/plot_point.dart';
import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:digital_shores/app/presentation/pages/plot/widgets/google_plot_map.dart';
import 'package:digital_shores/app/presentation/pages/plot/widgets/offline_plot_canvas.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlotMapView extends StatefulWidget {
  const PlotMapView({
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
  State<PlotMapView> createState() => _PlotMapViewState();
}

class _PlotMapViewState extends State<PlotMapView> {
  late Future<bool> _canUseOnlineMap;
  Timer? _onlineMapStartupTimer;
  bool _onlineMapReady = false;
  bool _onlineMapTimedOut = false;

  @override
  void initState() {
    super.initState();
    _canUseOnlineMap = _checkOnlineMapAvailability();
  }

  @override
  void dispose() {
    _onlineMapStartupTimer?.cancel();
    super.dispose();
  }

  Future<bool> _checkOnlineMapAvailability() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return false;
    }

    try {
      final response = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _canUseOnlineMap,
      builder: (context, snapshot) {
        final canUseOnlineMap = snapshot.data == true;
        final useOnlineMap = canUseOnlineMap && !_onlineMapTimedOut;
        if (useOnlineMap && !_onlineMapReady) {
          _startOnlineMapStartupTimer();
        }

        final child = useOnlineMap
            ? GooglePlotMap(
                savedPlots: widget.savedPlots,
                draftPoints: widget.draftPoints,
                mode: widget.mode,
                selectedPlotId: widget.selectedPlotId,
                onPlotSelected: widget.onPlotSelected,
                onMapReady: _handleOnlineMapReady,
              )
            : OfflinePlotCanvas(
                savedPlots: widget.savedPlots,
                draftPoints: widget.draftPoints,
                mode: widget.mode,
                selectedPlotId: widget.selectedPlotId,
                onPlotSelected: widget.onPlotSelected,
              );

        return Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              left: 8,
              top: 8,
              child: _MapModeBadge(
                isOnline: useOnlineMap,
                isLoading: snapshot.connectionState != ConnectionState.done ||
                    (useOnlineMap && !_onlineMapReady),
              ),
            ),
            if (_selectedPlot != null)
              Positioned(
                left: 8,
                right: 64,
                bottom: 8,
                child: _SelectedPlotPanel(plot: _selectedPlot!),
              ),
          ],
        );
      },
    );
  }

  void _startOnlineMapStartupTimer() {
    if (_onlineMapStartupTimer != null) {
      return;
    }

    _onlineMapStartupTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || _onlineMapReady) {
        return;
      }
      setState(() {
        _onlineMapTimedOut = true;
      });
    });
  }

  void _handleOnlineMapReady() {
    _onlineMapStartupTimer?.cancel();
    _onlineMapStartupTimer = null;
    if (_onlineMapReady || !mounted) {
      return;
    }
    setState(() {
      _onlineMapReady = true;
    });
  }

  SavedPlot? get _selectedPlot {
    final selectedPlotId = widget.selectedPlotId;
    if (selectedPlotId == null) {
      return null;
    }
    for (final plot in widget.savedPlots) {
      if (plot.id == selectedPlotId) {
        return plot;
      }
    }
    return null;
  }
}

class _MapModeBadge extends StatelessWidget {
  const _MapModeBadge({
    required this.isOnline,
    required this.isLoading,
  });

  final bool isOnline;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? Colors.green.shade800 : Colors.grey.shade800;
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOnline ? Icons.map_outlined : Icons.grid_on_outlined,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              isLoading ? 'Memuat' : (isOnline ? 'Online' : 'Offline'),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedPlotPanel extends StatelessWidget {
  const _SelectedPlotPanel({required this.plot});

  final SavedPlot plot;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plot.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${plot.areaSquareMeters.toStringAsFixed(2)} m2 - '
              '${plot.isSynced ? 'Dikirim' : 'Belum dikirim'}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
