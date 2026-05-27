import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:digital_shores/app/presentation/pages/plot/painters/plot_overview_painter.dart';
import 'package:digital_shores/app/presentation/pages/plot/storage/plot_local_storage.dart';
import 'package:digital_shores/app/presentation/pages/plot/utils/plot_overview_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

class PlotOverviewPage extends StatefulWidget {
  const PlotOverviewPage({super.key});

  @override
  State<PlotOverviewPage> createState() => _PlotOverviewPageState();
}

class _PlotOverviewPageState extends State<PlotOverviewPage> {
  final PlotLocalStorage _plotLocalStorage = PlotLocalStorage();
  final TransformationController _transformationController =
      TransformationController();
  late Future<List<SavedPlot>> _plotsFuture;
  String? _selectedPlotId;
  Size _viewportSize = const Size(620, 620);
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _plotsFuture = _plotLocalStorage.getAllPlots();
    _transformationController.addListener(_handleTransformChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_handleTransformChanged);
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _refreshPlots() async {
    setState(() {
      _plotsFuture = _plotLocalStorage.getAllPlots();
    });
  }

  void _handleTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() < 0.001) {
      return;
    }
    setState(() {
      _currentScale = scale;
    });
  }

  void _focusPlot(PlotOverviewItem item) {
    if (_viewportSize.width <= 0 || _viewportSize.height <= 0) {
      return;
    }

    const targetScale = 2.2;
    final dx =
        (_viewportSize.width / 2) - (item.center.dx * targetScale);
    final dy =
        (_viewportSize.height / 2) - (item.center.dy * targetScale);

    _transformationController.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(targetScale);
    _currentScale = targetScale;
  }

  void _selectPlot(PlotOverviewItem item, {bool focus = true}) {
    setState(() {
      _selectedPlotId = item.plot.id;
    });
    if (focus) {
      _focusPlot(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plot Overview'),
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
                  'No saved plots yet.\nRecord and save a plot first.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final items = PlotOverviewLayout.build(plots);

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
                      label: 'Not submitted',
                    ),
                    _LegendChip(
                      color: Colors.green.shade300,
                      label: 'Submitted',
                    ),
                    const _LegendChip(
                      color: Colors.white,
                      label: 'Tap a plot to open details',
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
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item.plot.id == _selectedPlotId;
                    final chipColor = item.plot.isSynced
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
                            onTap: () => _selectPlot(item),
                            child: Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: chipColor,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${item.index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectPlot(item),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.plot.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.plot.isSynced
                                        ? 'Submitted'
                                        : 'Not submitted',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: item.plot.isSynced
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Open details',
                            onPressed: () {
                              context.push(
                                '/home/saved-plots/${item.plot.id}',
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
                child: RefreshIndicator(
                  onRefresh: _refreshPlots,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      SizedBox(
                        height: 620,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            _viewportSize = Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            );
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: InteractiveViewer(
                                transformationController:
                                    _transformationController,
                                constrained: false,
                                minScale: 0.35,
                                maxScale: 5.0,
                                boundaryMargin: const EdgeInsets.all(240),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapUp: (details) {
                                    for (final item in items.reversed) {
                                      if (item.path
                                          .contains(details.localPosition)) {
                                        _selectPlot(item, focus: false);
                                        return;
                                      }
                                    }
                                    setState(() {
                                      _selectedPlotId = null;
                                    });
                                  },
                                  child: CustomPaint(
                                    size: PlotOverviewLayout.canvasSize,
                                    painter: PlotOverviewPainter(
                                      items: items,
                                      selectedPlotId: _selectedPlotId,
                                      viewportScale: _currentScale,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Showing ${plots.length} saved plots from local storage.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
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
