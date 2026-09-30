import 'package:digital_shores/app/presentation/pages/plot/map/plot_map_mode.dart';
import 'package:digital_shores/app/presentation/pages/plot/models/plot_point.dart';
import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:digital_shores/app/presentation/pages/plot/widgets/offline_plot_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026);
  final plots = List.generate(2, (index) {
    final base = index * 0.02;
    return SavedPlot(
      id: '$index',
      name: 'Plot $index',
      points: [
        for (final offset in const [
          Offset.zero,
          Offset(0.001, 0),
          Offset(0.001, 0.001),
          Offset(0, 0.001)
        ])
          PlotPoint(
              latitude: -5 + base + offset.dy,
              longitude: 119 + base + offset.dx,
              accuracy: 1,
              recordedAt: now),
      ],
      areaSquareMeters: 100,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
      source: 'offline_gps',
    );
  });

  for (final mode in [PlotMapMode.recording, PlotMapMode.overview]) {
    testWidgets('$mode opens at minimum zoom and retains it on rebuild',
        (tester) async {
      Widget view(List<SavedPlot> savedPlots) => MaterialApp(
            home: SizedBox.expand(
                child: OfflinePlotCanvas(
              savedPlots: savedPlots,
              draftPoints: const [],
              mode: mode,
              selectedPlotId: null,
              onPlotSelected: (_) {},
            )),
          );
      await tester.binding.setSurfaceSize(const Size(360, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(view(const []));
      await tester.pumpAndSettle();
      await tester.pumpWidget(view(plots));
      await tester.pumpAndSettle();
      var viewer =
          tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
      expect(viewer.transformationController!.value.getMaxScaleOnAxis(),
          closeTo(viewer.minScale, 0.00001));
      final painter = tester
          .widget<CustomPaint>(find
              .descendant(
                  of: find.byType(OfflinePlotCanvas),
                  matching: find.byType(CustomPaint))
              .first)
          .painter! as OfflinePlotCanvasPainter;
      for (final item in painter.layout.savedItems) {
        final visible = MatrixUtils.transformRect(
            viewer.transformationController!.value, item.path.getBounds());
        expect(visible.left, greaterThanOrEqualTo(0));
        expect(visible.top, greaterThanOrEqualTo(0));
        expect(visible.right, lessThanOrEqualTo(360));
        expect(visible.bottom, lessThanOrEqualTo(720));
      }
      await tester.pumpWidget(view(plots));
      await tester.pumpAndSettle();
      viewer = tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
      expect(viewer.transformationController!.value.getMaxScaleOnAxis(),
          closeTo(viewer.minScale, 0.00001));
      final zoomedScale = (viewer.minScale + viewer.maxScale) / 2;
      viewer.transformationController!.value =
          Matrix4.diagonal3Values(zoomedScale, zoomedScale, zoomedScale);
      await tester.pumpWidget(view(plots));
      await tester.pumpAndSettle();
      viewer = tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
      expect(viewer.transformationController!.value.getMaxScaleOnAxis(),
          closeTo(zoomedScale, 0.00001));

      // Leaving and re-entering must restore the overview, not the old zoom.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(view(plots));
      await tester.pumpAndSettle();
      viewer = tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
      expect(viewer.transformationController!.value.getMaxScaleOnAxis(),
          closeTo(viewer.minScale, 0.00001));
    });
  }

  for (final saved in [plots, <SavedPlot>[]]) {
    testWidgets(
        'recording follows small draft with ${saved.length} saved plots',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final draft = <PlotPoint>[];
      var reset = 0;
      Widget view() => MaterialApp(
              home: OfflinePlotCanvas(
            savedPlots: saved,
            draftPoints: draft,
            mode: PlotMapMode.recording,
            selectedPlotId: null,
            onPlotSelected: (_) {},
            resetSignal: reset,
          ));
      Future<void> pump() async {
        await tester.pumpWidget(view());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      InteractiveViewer viewer() =>
          tester.widget(find.byType(InteractiveViewer));
      Rect draftOnScreen() {
        final painter = tester
            .widget<CustomPaint>(find
                .descendant(
                  of: find.byType(OfflinePlotCanvas),
                  matching: find.byType(CustomPaint),
                )
                .first)
            .painter! as OfflinePlotCanvasPainter;
        final points = painter.layout.draftOffsets.map((p) =>
            MatrixUtils.transformPoint(
                viewer().transformationController!.value, p));
        return points
            .map((p) => Rect.fromLTWH(p.dx, p.dy, 0, 0))
            .reduce((a, b) => a.expandToInclude(b));
      }

      await pump();
      final oldMaximum = viewer().maxScale;
      for (final offset in const [
        Offset.zero,
        Offset(0.00005, 0),
        Offset(0.00005, 0.00005),
        Offset(0, 0.00005)
      ]) {
        draft.add(PlotPoint(
            latitude: -4.99 + offset.dy,
            longitude: 119.01 + offset.dx,
            accuracy: 1,
            recordedAt: now));
        await pump();
        final bounds = draftOnScreen();
        expect(bounds.center.dx, closeTo(180, 1));
        expect(bounds.center.dy, closeTo(360, 1));
        expect(bounds.left, greaterThanOrEqualTo(32));
        expect(bounds.right, lessThanOrEqualTo(328));
        expect(bounds.top, greaterThanOrEqualTo(32));
        expect(bounds.bottom, lessThanOrEqualTo(688));
        if (draft.length >= 2) expect(bounds.width, greaterThan(120));
      }
      if (saved.isNotEmpty) expect(viewer().maxScale, greaterThan(oldMaximum));
      // Recreating the canvas with a draft (e.g. online fallback) also focuses it.
      await tester.pumpWidget(const SizedBox());
      await pump();
      expect(draftOnScreen().width, greaterThan(120));
      reset++;
      await pump();
      expect(viewer().transformationController!.value.getMaxScaleOnAxis(),
          closeTo(viewer().minScale, 0.00001));
      draft.removeLast();
      await pump();
      expect(draftOnScreen().width, greaterThan(120));
      while (draft.isNotEmpty) {
        draft.removeLast();
        await pump();
      }
      if (saved.isNotEmpty) {
        expect(viewer().maxScale, closeTo(oldMaximum, 0.00001));
        expect(viewer().transformationController!.value.getMaxScaleOnAxis(),
            closeTo(viewer().minScale, 0.00001));
      }
      // Coincident fixes and vertical lines must not produce an infinite scale.
      final point = PlotPoint(
          latitude: -4.99, longitude: 119.01, accuracy: 1, recordedAt: now);
      draft.add(point);
      await pump();
      final singleScale =
          viewer().transformationController!.value.getMaxScaleOnAxis();
      draft.add(point);
      await pump();
      expect(viewer().transformationController!.value.getMaxScaleOnAxis(),
          closeTo(singleScale, 0.00001));
      draft.add(PlotPoint(
          latitude: -4.98995, longitude: 119.01, accuracy: 1, recordedAt: now));
      await pump();
      expect(draftOnScreen().height, greaterThan(120));
      expect(draftOnScreen().center.dy, closeTo(360, 1));
    });
  }

  testWidgets(
      'overview zoom resolves actual short edges, including rotated plots',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    // A thin rotated plot: bounding-box dimensions cannot identify its short edge.
    final tiny = plots.first.copyWith(id: 'tiny', points: [
      for (final p in const [
        Offset(0, 0),
        Offset(0.000001, 0.000001),
        Offset(0.000101, -0.000099),
        Offset(0.0001, -0.0001)
      ])
        PlotPoint(
            latitude: -4.99 + p.dy,
            longitude: 119.01 + p.dx,
            accuracy: 1,
            recordedAt: now),
    ]);
    Future<InteractiveViewer> show(List<SavedPlot> saved) async {
      await tester.pumpWidget(MaterialApp(
          home: OfflinePlotCanvas(
        savedPlots: saved,
        draftPoints: const [],
        mode: PlotMapMode.overview,
        selectedPlotId: null,
        onPlotSelected: (_) {},
      )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      return tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
    }

    final original = await show(plots);
    final viewer = await show([...plots, tiny]);
    expect(viewer.maxScale, greaterThan(20));
    expect(viewer.maxScale, greaterThan(original.maxScale));
    expect(viewer.minScale, closeTo(original.minScale, 0.00001));
    final painter = tester
        .widget<CustomPaint>(find
            .descendant(
              of: find.byType(OfflinePlotCanvas),
              matching: find.byType(CustomPaint),
            )
            .first)
        .painter! as OfflinePlotCanvasPainter;
    expect(painter.layout.shortestSavedEdgeLength! * viewer.maxScale,
        closeTo((360 - 2 * 360 * 0.14) / 3, 0.001));
    viewer.transformationController!.value = Matrix4.diagonal3Values(
        viewer.maxScale, viewer.maxScale, viewer.maxScale);
    await tester.pumpAndSettle();
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(),
        closeTo(viewer.maxScale, 0.00001));
    final beforePan = tester
        .widget<CustomPaint>(find
            .descendant(
              of: find.byType(OfflinePlotCanvas),
              matching: find.byType(CustomPaint),
            )
            .first)
        .painter! as OfflinePlotCanvasPainter;
    final panned = viewer.transformationController!.value.clone();
    panned.storage[12] -= 100;
    viewer.transformationController!.value = panned;
    await tester.pumpAndSettle();
    final afterPan = tester
        .widget<CustomPaint>(find
            .descendant(
              of: find.byType(OfflinePlotCanvas),
              matching: find.byType(CustomPaint),
            )
            .first)
        .painter! as OfflinePlotCanvasPainter;
    expect(afterPan.visibleBounds, isNot(beforePan.visibleBounds));
    final reduced = await show(plots);
    expect(reduced.maxScale, closeTo(original.maxScale, 0.00001));
    expect(reduced.transformationController!.value.getMaxScaleOnAxis(),
        lessThanOrEqualTo(reduced.maxScale + 0.000001));
    final degenerate = tiny.copyWith(points: List.filled(4, tiny.points.first));
    final fallback = await show([degenerate]);
    expect(fallback.maxScale.isFinite, isTrue);
    expect(fallback.maxScale, greaterThanOrEqualTo(fallback.minScale));
  });
}
