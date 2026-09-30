import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:digital_shores/app/presentation/pages/plot/map/plot_map_mode.dart';
import 'package:digital_shores/app/presentation/pages/plot/storage/plot_local_storage.dart';
import 'package:digital_shores/app/presentation/pages/plot/widgets/plot_map_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum _PlotListFilter {
  all,
  synced,
  unsynced,
}

class PlotOverviewPage extends StatefulWidget {
  const PlotOverviewPage({super.key});

  @override
  State<PlotOverviewPage> createState() => _PlotOverviewPageState();
}

class _PlotOverviewPageState extends State<PlotOverviewPage> {
  final PlotLocalStorage _plotLocalStorage = PlotLocalStorage();
  late Future<List<SavedPlot>> _plotsFuture;
  String? _selectedPlotId;
  _PlotListFilter _selectedFilter = _PlotListFilter.all;

  @override
  void initState() {
    super.initState();
    _plotsFuture = _plotLocalStorage.getAllPlots();
  }

  void _selectPlot(SavedPlot? plot) {
    setState(() {
      _selectedPlotId = plot?.id;
    });
  }

  void _setFilter(_PlotListFilter filter) {
    setState(() {
      _selectedFilter = filter;
      _selectedPlotId = null;
    });
  }

  List<SavedPlot> _filterPlots(List<SavedPlot> plots) {
    return switch (_selectedFilter) {
      _PlotListFilter.all => plots,
      _PlotListFilter.synced => plots.where((plot) => plot.isSynced).toList(),
      _PlotListFilter.unsynced =>
        plots.where((plot) => !plot.isSynced).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar LahanKu'),
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
                  'Belum ada lahan yang disimpan.\nRekam dan simpan lahan terlebih dahulu.', //no saved plots, record and save a plot first
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterButton(
                        label: 'All',
                        isSelected: _selectedFilter == _PlotListFilter.all,
                        onPressed: () => _setFilter(_PlotListFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        label: 'Dikirim',
                        isSelected: _selectedFilter == _PlotListFilter.synced,
                        onPressed: () => _setFilter(_PlotListFilter.synced),
                      ),
                      const SizedBox(width: 8),
                      _FilterButton(
                        label: 'Belum dikirim',
                        isSelected: _selectedFilter == _PlotListFilter.unsynced,
                        onPressed: () => _setFilter(_PlotListFilter.unsynced),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 92,
                child: filteredPlots.isEmpty
                    ? const Center(
                        child: Text('Tidak ada lahan untuk filter ini.'),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        itemCount: filteredPlots.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final plot = filteredPlots[index];
                          final isSelected = plot.id == _selectedPlotId;
                          final chipColor = plot.isSynced
                              ? Colors.green.shade100
                              : Colors.orange.shade100;
                          final borderColor = isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black12;

                          return Container(
                            width: 240,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: borderColor,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: () => _selectPlot(plot),
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: chipColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectPlot(plot),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          plot.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          plot.isSynced
                                              ? 'Dikirim' // submitted
                                              : 'Belum dikirim', //not submitted
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: plot.isSynced
                                                ? Colors.green.shade800
                                                : Colors.orange.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Lihat detail', //see detail
                                  onPressed: () {
                                    context.push(
                                      '/home/saved-plots/${plot.id}',
                                    );
                                  },
                                  icon: const Icon(Icons.open_in_new),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: filteredPlots.isEmpty
                        ? const Center(
                            child: Text('Tidak ada lahan untuk filter ini.'),
                          )
                        : PlotMapView(
                            savedPlots: filteredPlots,
                            draftPoints: const [],
                            mode: PlotMapMode.overview,
                            selectedPlotId: _selectedPlotId,
                            onPlotSelected: _selectPlot,
                          ),
                  ),
                ),
              ),
            ],
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
