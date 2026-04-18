import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class RecordedPoint {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  const RecordedPoint({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });
}

class GpsRecordPage extends StatefulWidget {
  const GpsRecordPage({super.key});

  @override
  State<GpsRecordPage> createState() => _GpsRecordPageState();
}

class _GpsRecordPageState extends State<GpsRecordPage> {
  bool _isLoading = false;
  String _statusText = 'No location fetched yet';
  Position? _currentPosition;

  final List<RecordedPoint> _recordedPoints = [];

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _statusText = 'Checking location service...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _statusText = 'Location service is disabled';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

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

    if (_isTooCloseToLastRecordedPoint(_currentPosition!)) {
      setState(() {
        _statusText =
            'Current location is too close to the last recorded point';
      });
      return;
    }

    final point = RecordedPoint(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      accuracy: _currentPosition!.accuracy,
      timestamp: DateTime.now(),
    );

    setState(() {
      _recordedPoints.add(point);
      _statusText = 'Point ${_recordedPoints.length} recorded';
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

  bool _isTooCloseToLastRecordedPoint(Position currentPosition) {
    if (_recordedPoints.isEmpty) return false;

    final lastPoint = _recordedPoints.last;

    final distanceInMeters = Geolocator.distanceBetween(
      lastPoint.latitude,
      lastPoint.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    return distanceInMeters < 3;
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

    return Scaffold(
      appBar: AppBar(
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
                      'Current Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_statusText),
                    const SizedBox(height: 16),
                    Text('Latitude: $latText'),
                    const SizedBox(height: 8),
                    Text('Longitude: $lngText'),
                    const SizedBox(height: 8),
                    Text('Accuracy: $accuracyText'),
                    const SizedBox(height: 12),
                    Text('Recorded Points: ${_recordedPoints.length}'),
                    const SizedBox(height: 8),
                    Text(
                      _recordedPoints.length < 4
                          ? 'Preview mode: points and polyline'
                          : 'Preview mode: polygon',
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
                  label: Text(_isLoading ? 'Loading...' : 'Get Current Location'),
                ),
                ElevatedButton.icon(
                  onPressed: _recordCurrentPoint,
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('Record Point'),
                ),
                OutlinedButton.icon(
                  onPressed: _undoLastPoint,
                  icon: const Icon(Icons.undo),
                  label: const Text('Undo'),
                ),
                OutlinedButton.icon(
                  onPressed: _clearAllPoints,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Shape Preview',
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
                    ? const Center(
                  child: Text('No preview yet'),
                )
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
                        currentPosition: _currentPosition,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recorded Point List',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _recordedPoints.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No points recorded yet'),
              ),
            )
                : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recordedPoints.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final point = _recordedPoints[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
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

class PlotPreviewPainter extends CustomPainter {
  final List<RecordedPoint> points;
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

    final previewPoints = <RecordedPoint>[
      ...points,
      if (currentPosition != null)
        RecordedPoint(
          latitude: currentPosition!.latitude,
          longitude: currentPosition!.longitude,
          accuracy: currentPosition!.accuracy,
          timestamp: DateTime.now(),
        ),
    ];

    if (previewPoints.isEmpty) return;

    final mappedPreviewPoints = _mapPointsToCanvas(previewPoints, size);
    final mappedRecordedPoints =
        mappedPreviewPoints.take(points.length).toList();

    final linePaint = Paint()
      ..color = Colors.blue.shade700
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.20)
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

    final textStyle = TextStyle(
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

      if (mappedRecordedPoints.length >= 4) {
        path.close();
        canvas.drawPath(path, fillPaint);
      }

      canvas.drawPath(path, linePaint);
    }

    for (int i = 0; i < mappedRecordedPoints.length; i++) {
      final point = mappedRecordedPoints[i];
      canvas.drawCircle(point, 10, recordedPointPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: textStyle,
        ),
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

  List<Offset> _mapPointsToCanvas(List<RecordedPoint> sourcePoints, Size size) {
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

    return sourcePoints.map((p) {
      final x = padding + ((p.longitude - minLng) / lngRange) * usableWidth;
      final y = size.height -
          padding -
          ((p.latitude - minLat) / latRange) * usableHeight;
      return Offset(x, y);
    }).toList();
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