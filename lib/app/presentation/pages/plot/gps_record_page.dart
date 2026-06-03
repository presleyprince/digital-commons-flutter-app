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
        title: 'Lahan sudah selesai', //farm plot is already complete
        message: 'Lahan ini sudah memiliki 4 titik. Simpan atau hapus titik terlebih dahulu sebelum mengambil lokasi lain.', //This plot already has 4 points. Save it or clear points before getting another location.
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusText = 'Memeriksa layanan lokasi...'; //checking location services
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _statusText = 'Layanan lokasi mati'; //location service is off
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
          _statusText = 'Akses izin lokasi ditolak'; //location access permission denied
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _statusText =
              'Izin lokasi ditolak secara permanen. Aktifkan di pengaturan sistem.'; //Location permission permanently denied. Enable it in system settings
        });
        return;
      }

      setState(() {
        _statusText = 'Mengambil lokasi saat ini...'; //fetching current location 
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
            ? 'Lokasi berhasil diambil. Akurasi bagus' //Location fetched. Accuracy is good
            : 'Lokasi berhasil diambil, tetapi akurasi belum stabil'; //Location fetched, but accuracy is not stable yet
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusText = 'Gagal mendapatkan lokasi: $e'; //failed to get location
      });
    }
  }

  void _recordCurrentPoint() {
    if (_currentPosition == null) {
      setState(() {
        _statusText = 'Ambil lokasi saat ini sebelum merekam titik'; //get current location before recording a point
      });
      return;
    }

    if (_recordedPoints.length >= PlotGeometry.requiredPointCount) {
      _showAlertDialog(
        title: 'Batas maksimum titik tercapai', //max point limit reached
        message: 'Lahan segiempat harus memiliki tepat 4 titik.', //Quadrilateral plots must contain exactly 4 points
      );
      return;
    }

    if (PlotGeometry.isTooCloseToLastRecordedPoint(
      points: _recordedPoints,
      currentPosition: _currentPosition!,
    )) {
      setState(() {
        _statusText = 'Lokasi saat ini terlalu dekat dengan titik terakhir yang direkam.'; //Current location is too close to the last recorded point
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
          ? 'Titik 4 direkam. Lahan siap disimpan' //Point 4 recorded. Plot is ready to save
          : 'Titik ${_recordedPoints.length} direkam'; //Point ${_recordedPoints.length} recorded
    });
  }

  void _undoLastPoint() {
    if (_recordedPoints.isEmpty) {
      setState(() {
        _statusText = 'Tidak ada titik yang dapat dibatalkan'; //no point to undo
      });
      return;
    }

    setState(() {
      _recordedPoints.removeLast();
      _statusText = 'Titik terakhir dihapus'; //last point removed
    });
  }

  void _clearAllPoints() {
    setState(() {
      _recordedPoints.clear();
      _statusText = 'Semua titik yang direkam telah dihapus'; //all recorded points cleared
    });
  }

  Future<void> _savePlot() async {
    if (_recordedPoints.length != PlotGeometry.requiredPointCount) {
      await _showAlertDialog(
        title: 'Gagal menyimpan lahan', //unable to save plots
        message: 'Hanya lahan segiempat dengan tepat 4 titik yang dapat disimpan.', //Only quadrilateral plots with exactly 4 points can be saved.
      );
      return;
    }

    final customName = await _promptPlotName();
    if (!mounted || customName == null) return;

    final now = DateTime.now();
    final timestamp = DateFormat('yyyy-MM-dd HH:mm').format(now);
    final trimmedName = customName.trim();
    final plotName =
        trimmedName.isEmpty ? 'Lahan $timestamp' : '$trimmedName - $timestamp';

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
        _statusText = '${plot.name} berhasil disimpan'; //saved successfully
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${plot.name} disimpan')), //saved
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _statusText = 'Gagal menyimpan lahan: $e'; //failed to save plot
      });
      await _showAlertDialog(
        title: 'Gagal menyimpan lahan:', //failed to save plot
        message: 'Terjadi kesalahan saat menyimpan lahan ini.\n\n$e', //error occurred while saving this plot
      );
    }
  }

  Future<String?> _promptPlotName() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Simpan Lahan'), //save plot
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Masukkan nama lahan atau lewati untuk menggunakan nama otomatis.'), //enter plot name or skip for automatic name
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nama lahan', //plot name
                  hintText: 'Opsional', //optional
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null), 
              child: const Text('Batal'), //cancel
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(''),
              child: const Text('Lewati'), //skip
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Simpan Lahan'), //save farm
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
        title: const Text('Pemetaan Lahan'), //plot/farm mapping 
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
                          ? 'Mode pratinjau: titik dan garis tepi' //Preview mode: points and polyline/border lines
                          : 'Mode pratinjau: poligon', //Preview mode: polygon
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
                          'Akurasi: ${point.accuracy.toStringAsFixed(2)} m', //accuracy
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
