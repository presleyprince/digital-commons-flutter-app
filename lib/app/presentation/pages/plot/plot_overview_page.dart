import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:digital_shores/app/presentation/pages/plot/map/plot_map_mode.dart';
import 'package:digital_shores/app/presentation/pages/plot/storage/plot_local_storage.dart';
import 'package:digital_shores/app/presentation/pages/plot/widgets/plot_map_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlotOverviewPage extends StatefulWidget {
  const PlotOverviewPage({super.key});

  @override
  State<PlotOverviewPage> createState() => _PlotOverviewPageState();
}

class _PlotOverviewPageState extends State<PlotOverviewPage> {
  final PlotLocalStorage _plotLocalStorage = PlotLocalStorage();
  late Future<List<SavedPlot>> _plotsFuture;
  String? _selectedPlotId;

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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _LegendChip(
                      color: Colors.orange.shade300,
                      label: 'Belum dikirim', //not submitted
                    ),
                    _LegendChip(
                      color: Colors.green.shade300,
                      label: 'Dikirim ', //submitted
                    ),
                    const _LegendChip(
                      color: Colors.white,
                      label:
                          'Ketuk lahan untuk melihat detail ', //tap land to see details
                      borderColor: Colors.black26,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  itemCount: plots.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final plot = plots[index];
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
                            ? Theme.of(context).colorScheme.primaryContainer
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
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
                    child: PlotMapView(
                      savedPlots: plots,
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

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
    this.borderColor,
  });

  final Color color;
  final String label;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor ?? Colors.transparent),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
