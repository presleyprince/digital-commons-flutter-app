import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:digital_shores/app/presentation/pages/plot/storage/plot_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SavedPlotsPage extends StatefulWidget {
  const SavedPlotsPage({super.key});

  @override
  State<SavedPlotsPage> createState() => _SavedPlotsPageState();
}

class _SavedPlotsPageState extends State<SavedPlotsPage> {
  final PlotLocalStorage _plotLocalStorage = PlotLocalStorage();
  late Future<List<SavedPlot>> _plotsFuture;

  Color _statusColor(BuildContext context, bool isSynced) {
    return isSynced
        ? Colors.green.shade100
        : Theme.of(context).colorScheme.secondaryContainer;
  }

  Color _statusTextColor(bool isSynced) {
    return isSynced ? Colors.green.shade900 : Colors.orange.shade900;
  }

  String _statusLabel(bool isSynced) {
    return isSynced ? 'Dikirim' : 'Belum dikirim'; //submitted/ not submitted
  }

  @override
  void initState() {
    super.initState();
    _plotsFuture = _plotLocalStorage.getAllPlots();
  }

  Future<void> _refreshPlots() async {
    setState(() {
      _plotsFuture = _plotLocalStorage.getAllPlots();
    });
  }

  Future<void> _deletePlot(SavedPlot plot) async {
    await _plotLocalStorage.deletePlot(plot.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${plot.name} dihapus')), //deleted
    );
    await _refreshPlots();
  }

  Future<void> _confirmDelete(SavedPlot plot) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus lahan?'), //delete plot?
          content: Text('Hapus ${plot.name}? Tindakan ini tidak dapat dibatalkan.'), //Delete ${plot.name}? This cannot be undone.
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),//cancel
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'), //delete
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deletePlot(plot);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lahan yang Disimpan'), //saved plots
      ),
      body: FutureBuilder<List<SavedPlot>>(
        future: _plotsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final plots = snapshot.data ?? const <SavedPlot>[];
          if (plots.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada lahan yang disimpan.\nRekam dan simpan lahan terlebih dahulu.', //No saved plots yet.\nRecord and save a plot first.
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshPlots,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: plots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final plot = plots[index];
                return Card(
                  child: ListTile(
                    onTap: () async {
                      await context.push('/home/saved-plots/${plot.id}');
                      if (!mounted) return;
                      await _refreshPlots();
                    },
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(plot.name),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(context, plot.isSynced),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _statusLabel(plot.isSynced),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _statusTextColor(plot.isSynced),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Luas: ${plot.areaSquareMeters.toStringAsFixed(2)} m^2\n' //area
                      'Diperbarui : ${dateFormat.format(plot.updatedAt)}\n' //Updated
                      'Titik koordinat: ${plot.points.length}/4', //Vertices
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      onPressed: () => _confirmDelete(plot),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
