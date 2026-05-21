import 'package:digital_shores/app/presentation/pages/plot/models/plot_point.dart';
import 'package:digital_shores/app/presentation/pages/plot/models/saved_plot.dart';
import 'package:digital_shores/app/presentation/pages/plot/utils/plot_geometry.dart';
import 'package:digital_shores/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class PlotLocalStorage {
  PlotLocalStorage({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  final DatabaseHelper _databaseHelper;

  Future<void> savePlot(SavedPlot plot) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.insert(
        'saved_plots',
        plot.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.delete(
        'saved_plot_points',
        where: 'plot_id = ?',
        whereArgs: [plot.id],
      );

      for (int i = 0; i < plot.points.length; i++) {
        await txn.insert(
          'saved_plot_points',
          plot.points[i].toMap(plotId: plot.id, pointOrder: i),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<SavedPlot>> getAllPlots() async {
    final db = await _databaseHelper.database;
    final plots = await db.query(
      'saved_plots',
      orderBy: 'updated_at DESC',
    );

    final result = <SavedPlot>[];
    for (final plotMap in plots) {
      final points = await _getPointsForPlot(db, plotMap['id'] as String);
      result.add(
        SavedPlot.fromMap(
          {
            ...plotMap,
            'area_square_meters': PlotGeometry.calculatePolygonAreaSquareMeters(points),
          },
          points,
        ),
      );
    }
    return result;
  }

  Future<SavedPlot?> getPlotById(String id) async {
    final db = await _databaseHelper.database;
    final plots = await db.query(
      'saved_plots',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (plots.isEmpty) return null;

    final points = await _getPointsForPlot(db, id);
    return SavedPlot.fromMap(
      {
        ...plots.first,
        'area_square_meters': PlotGeometry.calculatePolygonAreaSquareMeters(points),
      },
      points,
    );
  }

  Future<void> deletePlot(String id) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'saved_plot_points',
        where: 'plot_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'saved_plots',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> updatePlotSyncStatus({
    required String plotId,
    required bool isSynced,
  }) async {
    final db = await _databaseHelper.database;
    await db.update(
      'saved_plots',
      {
        'is_synced': isSynced ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [plotId],
    );
  }

  Future<List<PlotPoint>> _getPointsForPlot(Database db, String plotId) async {
    final points = await db.query(
      'saved_plot_points',
      where: 'plot_id = ?',
      whereArgs: [plotId],
      orderBy: 'point_order ASC',
    );

    return points.map(PlotPoint.fromMap).toList();
  }
}
