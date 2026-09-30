import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:digital_shores/app/presentation/pages/plot/storage/plot_local_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum _SavedPlotFilter {
  all,
  synced,
  unsynced,
}

class SavedPlotsPage extends StatefulWidget {
  const SavedPlotsPage({super.key});

  @override
  State<SavedPlotsPage> createState() => _SavedPlotsPageState();
}

class _SavedPlotsPageState extends State<SavedPlotsPage> {
  final PlotLocalStorage _plotLocalStorage = PlotLocalStorage();
  late Future<List<SavedPlot>> _plotsFuture;
  _SavedPlotFilter _selectedFilter = _SavedPlotFilter.all;

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

  void _setFilter(_SavedPlotFilter filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  List<SavedPlot> _filterPlots(List<SavedPlot> plots) {
    return switch (_selectedFilter) {
      _SavedPlotFilter.all => plots,
      _SavedPlotFilter.synced => plots.where((plot) => plot.isSynced).toList(),
      _SavedPlotFilter.unsynced =>
        plots.where((plot) => !plot.isSynced).toList(),
    };
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
          content: Text(
              'Hapus ${plot.name}? Tindakan ini tidak dapat dibatalkan.'), //Delete ${plot.name}? This cannot be undone.
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'), //cancel
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
          final filteredPlots = _filterPlots(plots);
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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterButton(
                        label: 'All',
                        isSelected: _selectedFilter == _SavedPlotFilter.all,
                        onPressed: () => _setFilter(_SavedPlotFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        label: 'Dikirim',
                        isSelected: _selectedFilter == _SavedPlotFilter.synced,
                        onPressed: () => _setFilter(_SavedPlotFilter.synced),
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        label: 'Belum dikirim',
                        isSelected:
                            _selectedFilter == _SavedPlotFilter.unsynced,
                        onPressed: () => _setFilter(_SavedPlotFilter.unsynced),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (filteredPlots.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('Tidak ada lahan untuk filter ini.'),
                    ),
                  )
                else
                  for (final entry in filteredPlots.asMap().entries) ...[
                    _SavedPlotCard(
                      plot: entry.value,
                      dateFormat: dateFormat,
                      statusColor: _statusColor(context, entry.value.isSynced),
                      statusTextColor: _statusTextColor(entry.value.isSynced),
                      statusLabel: _statusLabel(entry.value.isSynced),
                      onTap: () async {
                        await context
                            .push('/home/saved-plots/${entry.value.id}');
                        if (!mounted) return;
                        await _refreshPlots();
                      },
                      onDelete: () => _confirmDelete(entry.value),
                    ),
                    if (entry.key != filteredPlots.length - 1)
                      const SizedBox(height: 12),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => onPressed(),
      selectedColor: colorScheme.primaryContainer,
      side: BorderSide(
        color: isSelected ? colorScheme.primary : Colors.black12,
      ),
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimaryContainer : Colors.black87,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SavedPlotCard extends StatelessWidget {
  const _SavedPlotCard({
    required this.plot,
    required this.dateFormat,
    required this.statusColor,
    required this.statusTextColor,
    required this.statusLabel,
    required this.onTap,
    required this.onDelete,
  });

  final SavedPlot plot;
  final DateFormat dateFormat;
  final Color statusColor;
  final Color statusTextColor;
  final String statusLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
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
                color: statusColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusTextColor,
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
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }
}
