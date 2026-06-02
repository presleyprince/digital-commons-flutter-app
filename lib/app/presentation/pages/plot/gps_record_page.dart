import 'package:digital_shores/app/presentation/pages/plot/models/plot_point.dart';
import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:digital_shores/app/presentation/pages/plot/painters/plot_preview_painter.dart';
import 'package:digital_shores/app/presentation/pages/plot/storage/plot_local_storage.dart';
import 'package:digital_shores/app/presentation/pages/plot/utils/plot_geometry.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class GpsRecordPage extends StatefulWidget {
  const GpsRecordPage({super.key});

  @override
  State<GpsRecordPage> createState() => _GpsRecordPageState();
}

class _GpsRecordPageState extends State<GpsRecordPage> {
  final PlotLocalStorage _plotLocalStorage = PlotLocalStorage();
  final Uuid _uuid = const Uuid();

  bool _isLoading = false;
  bool _isSaving = false;
  String _statusText = 'Belum ada lokasi'; //no location yet
  Position? _currentPosition;
  final List<PlotPoint> _recordedPoints = [];

  Future<void> _getCurrentLocation() async {
    if (_recordedPoints.length >= PlotGeometry.requiredPointCount) {
      await _showAlertDialog(
        title: 'Plot already complete',
        message: 'This plot already has 4 points. Save it or clear points before getting another location.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusText = 'Checking location service...';
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _statusText = 'Location service is disabled';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _statusText = 'Location permission denied';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _statusText =
              'Location permission permanently denied. Enable it in system settings';
        });
        return;
      }

      setState(() {
        _statusText = 'Fetching current location...';
      });

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
        _statusText = position.accuracy <= 10
            ? 'Location fetched. Accuracy is good'
            : 'Location fetched, but accuracy is not stable yet';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusText = 'Failed to get location: $e';
      });
    }
  }

  void _recordCurrentPoint() {
    if (_currentPosition == null) {
      setState(() {
        _statusText = 'Fetch current location before recording a point';
      });
      return;
    }

    if (_recordedPoints.length >= PlotGeometry.requiredPointCount) {
      _showAlertDialog(
        title: 'Maximum points reached',
        message: 'Quadrilateral plots must contain exactly 4 points.',
      );
      return;
    }

    if (PlotGeometry.isTooCloseToLastRecordedPoint(
      points: _recordedPoints,
      currentPosition: _currentPosition!,
    )) {
      setState(() {
        _statusText = 'Current location is too close to the last recorded point';
      });
      return;
    }

    final point = PlotPoint(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      accuracy: _currentPosition!.accuracy,
      recordedAt: DateTime.now(),
    );

    setState(() {
      _recordedPoints.add(point);
      _statusText = _recordedPoints.length == PlotGeometry.requiredPointCount
          ? 'Point 4 recorded. Plot is ready to save'
          : 'Point ${_recordedPoints.length} recorded';
    });
  }

  void _undoLastPoint() {
    if (_recordedPoints.isEmpty) {
      setState(() {
        _statusText = 'No point to undo';
      });
      return;
    }

    setState(() {
      _recordedPoints.removeLast();
      _statusText = 'Last point removed';
    });
  }

  void _clearAllPoints() {
    setState(() {
      _recordedPoints.clear();
      _statusText = 'All recorded points cleared';
    });
  }

  Future<void> _savePlot() async {
    if (_recordedPoints.length != PlotGeometry.requiredPointCount) {
      await _showAlertDialog(
        title: 'Unable to save plot',
        message: 'Only quadrilateral plots with exactly 4 points can be saved.',
      );
      return;
    }

    final customName = await _promptPlotName();
    if (!mounted || customName == null) return;

    final now = DateTime.now();
    final timestamp = DateFormat('yyyy-MM-dd HH:mm').format(now);
    final trimmedName = customName.trim();
    final plotName =
        trimmedName.isEmpty ? 'Plot $timestamp' : '$trimmedName - $timestamp';

    final plot = SavedPlot(
      id: _uuid.v4(),
      name: plotName,
      points: List<PlotPoint>.from(_recordedPoints),
      areaSquareMeters: PlotGeometry.calculatePolygonAreaSquareMeters(
        _recordedPoints,
      ),
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      source: 'offline_gps',
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await _plotLocalStorage.savePlot(plot);
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _recordedPoints.clear();
        _statusText = '${plot.name} saved successfully';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${plot.name} saved')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _statusText = 'Failed to save plot: $e';
      });
      await _showAlertDialog(
        title: 'Failed to save plot',
        message: 'An error occurred while saving this plot.\n\n$e',
      );
    }
  }

  Future<String?> _promptPlotName() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Plot'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter a plot name or skip to use an automatic name.'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Plot name',
                  hintText: 'Optional',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(''),
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    return result;
  }

  Future<void> _showAlertDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final latText = _currentPosition == null
        ? '--'
        : _currentPosition!.latitude.toStringAsFixed(6);
    final lngText = _currentPosition == null
        ? '--'
        : _currentPosition!.longitude.toStringAsFixed(6);
    final accuracyText = _currentPosition == null
        ? '--'
        : '${_currentPosition!.accuracy.toStringAsFixed(2)} m';
    final areaSquareMeters =
        PlotGeometry.calculatePolygonAreaSquareMeters(_recordedPoints);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
            context.go('/home/seaweed-home');
          },
        ),
        title: const Text('GPS Plot Recorder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status saat ini', //current status
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_statusText),
                    const SizedBox(height: 16),
                    Text('Garis lintang: $latText'), //latitude
                    const SizedBox(height: 8),
                    Text('Garis bujur: $lngText'), //longitude
                    const SizedBox(height: 8),
                    Text('Ketepatan: $accuracyText'), //accuracy
                    const SizedBox(height: 12),
                    Text('Poin Tercatat: ${_recordedPoints.length}/4'), //recorded points
                    const SizedBox(height: 8),
                    Text(
                      _recordedPoints.length < PlotGeometry.requiredPointCount
                          ? 'Preview mode: points and polyline'
                          : 'Preview mode: polygon',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recordedPoints.length < PlotGeometry.requiredPointCount
                          ? 'Bidang: Tidak tersedia' //area, not available
                          : 'Bidang: ${areaSquareMeters.toStringAsFixed(2)} m^2',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: Text(_isLoading ? 'Menunggu...' : 'Dapatkan lokasi saat ini'), //waiting, get current location
                ),
                ElevatedButton.icon(
                  onPressed: _recordCurrentPoint,
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('Rekam titik'), //record point
                ),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _savePlot,
                  icon: const Icon(Icons.save_alt),
                  label: Text(_isSaving ? 'Menyimpan...' : 'Simpan kavling'), //saving files, save plot
                ),
                OutlinedButton.icon(
                  onPressed: _undoLastPoint,
                  icon: const Icon(Icons.undo),
                  label: const Text('Membuka'), //undo
                ),
                OutlinedButton.icon(
                  onPressed: _clearAllPoints,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Menghapus'), //remove
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Pratinjau', //preview
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: _recordedPoints.isEmpty
                    ? const Center(child: Text('Tidak ada pratinjau')) //no preview
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 8.0,
                          boundaryMargin: const EdgeInsets.all(80),
                          child: CustomPaint(
                            size: const Size(320, 320),
                            painter: PlotPreviewPainter(
                              points: _recordedPoints,
                              currentPosition:
                                  _recordedPoints.length >= PlotGeometry.requiredPointCount
                                  ? null
                                  : _currentPosition,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Poin yang tercatat', //recorded points
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _recordedPoints.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Belum ada poin yang tercatat')), //no recorded points yet
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recordedPoints.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final point = _recordedPoints[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(
                          '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
                        ),
                        subtitle: Text(
                          'Accuracy: ${point.accuracy.toStringAsFixed(2)} m',
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
