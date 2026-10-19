import 'package:digital_shores/app/presentation/pages/plot/models/plot_point.dart';
import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:digital_shores/app/presentation/pages/plot/map/plot_map_mode.dart';
import 'package:digital_shores/app/presentation/pages/plot/storage/plot_local_storage.dart';
import 'package:digital_shores/app/presentation/pages/plot/utils/plot_geometry.dart';
import 'package:digital_shores/app/presentation/pages/plot/widgets/plot_map_view.dart';
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
  bool _isLeaving = false;
  int _mapResetSignal = 0;
  final List<PlotPoint> _recordedPoints = [];
  late Future<List<SavedPlot>> _savedPlotsFuture;

  bool get _hasUnsavedPoints => _recordedPoints.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _savedPlotsFuture = _plotLocalStorage.getAllPlots();
  }

  Future<Position?> _getCurrentLocation() async {
    if (_recordedPoints.length >= PlotGeometry.requiredPointCount) {
      await _showAlertDialog(
        title: 'Plot already complete',
        message:
            'This plot already has 4 points. Save it or use Ulang before recording another location.',
      );
      return null;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
        });
        _showStatusMessage('Layanan lokasi mati');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
        });
        _showStatusMessage('Akses izin lokasi ditolak');
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        _showStatusMessage(
          'Izin lokasi ditolak secara permanen. Aktifkan di pengaturan sistem.',
        );
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _isLoading = false;
      });
      _showStatusMessage(
        position.accuracy <= 10
            ? 'Lokasi berhasil diambil. Akurasi bagus'
            : 'Lokasi berhasil diambil, tetapi akurasi belum stabil',
      );
      return position;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showStatusMessage('Gagal mendapatkan lokasi: $e');
      return null;
    }
  }

  Future<void> _recordCurrentPoint() async {
    if (_recordedPoints.length >= PlotGeometry.requiredPointCount) {
      _showAlertDialog(
        title: 'Batas maksimum titik tercapai', //max point limit reached
        message:
            'Lahan segiempat harus memiliki tepat 4 titik.', //Quadrilateral plots must contain exactly 4 points
      );
      return;
    }

    final position = await _getCurrentLocation();
    if (position == null) {
      return;
    }

    if (PlotGeometry.isTooCloseToLastRecordedPoint(
      points: _recordedPoints,
      currentPosition: position,
    )) {
      _showStatusMessage(
        'Lokasi saat ini terlalu dekat dengan titik terakhir yang direkam.',
      );
      return;
    }

    final point = PlotPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      recordedAt: DateTime.now(),
    );

    setState(() {
      _recordedPoints.add(point);
    });
    _showStatusMessage(
      _recordedPoints.length == PlotGeometry.requiredPointCount
          ? 'Titik 4 direkam. Lahan siap disimpan'
          : 'Titik ${_recordedPoints.length} direkam',
    );
  }

  void _undoLastPoint() {
    if (_recordedPoints.isEmpty) {
      _showStatusMessage('Tidak ada titik yang dapat dibatalkan');
      return;
    }

    setState(() {
      _recordedPoints.removeLast();
    });
    _showStatusMessage('Titik terakhir dihapus');
  }

  Future<bool> _savePlotWithName(String customName) async {
    if (_recordedPoints.length != PlotGeometry.requiredPointCount) {
      await _showAlertDialog(
        title: 'Gagal menyimpan lahan', //unable to save plots
        message:
            'Hanya lahan segiempat dengan tepat 4 titik yang dapat disimpan.', //Only quadrilateral plots with exactly 4 points can be saved.
      );
      return false;
    }

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
      if (!mounted) return false;

      setState(() {
        _isSaving = false;
        _recordedPoints.clear();
        _savedPlotsFuture = _plotLocalStorage.getAllPlots();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${plot.name} disimpan')), //saved
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
      });
      await _showAlertDialog(
        title: 'Gagal menyimpan lahan:', //failed to save plot
        message:
            'Terjadi kesalahan saat menyimpan lahan ini.\n\n$e', //error occurred while saving this plot
      );
      return false;
    }
  }

  Future<void> _handleDonePressed() async {
    if (_recordedPoints.length != PlotGeometry.requiredPointCount) {
      await _showAlertDialog(
        title: 'Gagal menyimpan lahan', //unable to save plots
        message:
            'Hanya lahan segiempat dengan tepat 4 titik yang dapat disimpan.', //Only quadrilateral plots with exactly 4 points can be saved.
      );
      return;
    }

    await _showPlotDetailsSheet();
  }

  Future<void> _showPlotDetailsSheet() async {
    final shouldExit = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(sheetContext).pop(false),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: _PlotDetailsSheet(
                points: List<PlotPoint>.from(_recordedPoints),
                isSaving: _isSaving,
                onSave: _savePlotWithName,
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || shouldExit != true) {
      return;
    }
    _exitPage();
  }

  void _resetMapView() {
    setState(() {
      _mapResetSignal++;
    });
  }

  void _showStatusMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

  Future<bool> _confirmDiscardUnsavedPoints() async {
    if (!_hasUnsavedPoints) {
      return true;
    }

    final color = Theme.of(context).colorScheme;

    final shouldExit = await showDialog<bool>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade600,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                'Lahan belum disimpan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Anda memiliki titik yang belum disimpan. Pilih Keluar untuk membuang titik tersebut atau tetap di halaman ini.',
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: color.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Tetap di halaman', textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color.primary,
                    side: BorderSide(color: color.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Keluar', textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

    return shouldExit ?? false;
  }

  void _exitPage() {
    if (mounted) {
      setState(() {
        _isLeaving = true;
      });
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    context.go('/home/seaweed-home');
  }

  Future<void> _handleBackPressed() async {
    final shouldExit = await _confirmDiscardUnsavedPoints();
    if (!mounted || !shouldExit) {
      return;
    }
    _exitPage();
  }

  @override
  Widget build(BuildContext context) {
    final canUndo = _recordedPoints.isNotEmpty;
    final canRecord =
        !_isLoading && _recordedPoints.length < PlotGeometry.requiredPointCount;

    return PopScope(
      canPop: !_hasUnsavedPoints || _isLeaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _handleBackPressed();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: FutureBuilder<List<SavedPlot>>(
                future: _savedPlotsFuture,
                builder: (context, snapshot) {
                  final savedPlots = snapshot.data ?? const <SavedPlot>[];
                  if (snapshot.connectionState != ConnectionState.done &&
                      _recordedPoints.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return PlotMapView(
                    savedPlots: savedPlots,
                    draftPoints: _recordedPoints,
                    mode: PlotMapMode.recording,
                    selectedPlotId: null,
                    onPlotSelected: (_) {},
                    resetSignal: _mapResetSignal,
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _MapCircleButton(
                          icon: Icons.close_rounded,
                          tooltip: 'Batal',
                          onPressed: _handleBackPressed,
                        ),
                        const Spacer(),
                        _MapCircleButton(
                          icon: Icons.check_rounded,
                          tooltip: 'Selesai',
                          onPressed: _handleDonePressed,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _MapCircleButton(
                          icon: Icons.undo_rounded,
                          tooltip: 'Ulang',
                          onPressed: canUndo ? _undoLastPoint : null,
                          size: 62,
                        ),
                        const Spacer(),
                        _MapCircleButton(
                          icon: _isLoading
                              ? Icons.hourglass_top_rounded
                              : Icons.add_location_alt_rounded,
                          tooltip: 'Rekam titik',
                          onPressed: canRecord ? _recordCurrentPoint : null,
                          size: 94,
                          iconSize: 38,
                        ),
                        const Spacer(),
                        _MapCircleButton(
                          icon: Icons.my_location_rounded,
                          tooltip: 'Reset tampilan',
                          onPressed: _resetMapView,
                          size: 62,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCircleButton extends StatelessWidget {
  const _MapCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 66,
    this.iconSize = 28,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Material(
      color: onPressed == null
          ? color.primary.withValues(alpha: 0.45)
          : color.primary.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: iconSize,
              color: color.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlotDetailsSheet extends StatefulWidget {
  const _PlotDetailsSheet({
    required this.points,
    required this.isSaving,
    required this.onSave,
  });

  final List<PlotPoint> points;
  final bool isSaving;
  final Future<bool> Function(String name) onSave;

  @override
  State<_PlotDetailsSheet> createState() => _PlotDetailsSheetState();
}

class _PlotDetailsSheetState extends State<_PlotDetailsSheet> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isSaving = widget.isSaving;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    final saved = await widget.onSave(_nameController.text);
    if (!mounted) {
      return;
    }

    if (saved) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return FractionallySizedBox(
      heightFactor: 0.78,
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 300) {
            Navigator.of(context).pop(false);
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                14,
                24,
                20 + bottomInset,
              ),
              child: ListView(
                children: [
                  Row(
                    children: [
                      _MapCircleButton(
                        icon: Icons.keyboard_arrow_down_rounded,
                        tooltip: 'Tutup',
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: _isSaving ? null : _save,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(_isSaving ? 'Menyimpan...' : 'Simpan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Informasi Lahan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Nama',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Isi nama plot di sini',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Koordinat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (var i = 0; i < widget.points.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${i + 1}. ${widget.points[i].latitude.toStringAsFixed(6)}, '
                        '${widget.points[i].longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  const SizedBox(height: 26),
                  const Text(
                    'Tambah Foto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _PhotoPlaceholder(),
                      SizedBox(width: 28),
                      _PhotoPlaceholder(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.add_rounded,
        size: 42,
        color: Colors.grey.shade700,
      ),
    );
  }
}
