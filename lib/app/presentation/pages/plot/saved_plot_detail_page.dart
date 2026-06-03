import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:digital_shores/app/presentation/pages/plot/painters/plot_preview_painter.dart';
import 'package:digital_shores/app/presentation/pages/plot/storage/plot_local_storage.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SavedPlotDetailPage extends StatefulWidget {
  const SavedPlotDetailPage({
    super.key,
    required this.plotId,
  });

  final String plotId;

  @override
  State<SavedPlotDetailPage> createState() => _SavedPlotDetailPageState();
}

class _SavedPlotDetailPageState extends State<SavedPlotDetailPage> {
  final PlotLocalStorage _plotLocalStorage = PlotLocalStorage();
  late Future<SavedPlot?> _plotFuture;

  @override
  void initState() {
    super.initState();
    _plotFuture = _plotLocalStorage.getPlotById(widget.plotId);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Lahan yang Disimpan'), //saved plot details
      ),
      body: FutureBuilder<SavedPlot?>(
        future: _plotFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final plot = snapshot.data;
          if (plot == null) {
            return const Center(child: Text('Lahan tidak ditemukan')); //plot not found 
          }

          return SingleChildScrollView(
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
                        Text(plot.name, style: kTitle5TextStyle),
                        const SizedBox(height: 12),
                        Text(
                          'Luas: ${plot.areaSquareMeters.toStringAsFixed(2)} m^2', //area
                        ),
                        const SizedBox(height: 8),
                        Text('Tiktik koordinat: ${plot.points.length}/4'), //verticies
                        const SizedBox(height: 8),
                        Text('Dibuat: ${dateFormat.format(plot.createdAt)}'), //creayed
                        const SizedBox(height: 8),
                        Text('Diperbarui: ${dateFormat.format(plot.updatedAt)}'), //updated
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await context.push('/home/saved-plots/${plot.id}/form');
                              if (!mounted) {
                                return;
                              }
                              setState(() {
                                _plotFuture = _plotLocalStorage.getPlotById(widget.plotId);
                              });
                            },
                            icon: const Icon(Icons.description_outlined),
                            label: const Text('Buka Formulir Lahan'), //open plot form
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pratinjau Bentuk', //shape preview
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 8.0,
                        boundaryMargin: const EdgeInsets.all(80),
                        child: CustomPaint(
                          size: const Size(320, 320),
                          painter: PlotPreviewPainter(
                            points: plot.points,
                            currentPosition: null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Daftar Titik yang Direkam', //recorded point list
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plot.points.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final point = plot.points[index];
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
          );
        },
      ),
    );
  }
}
