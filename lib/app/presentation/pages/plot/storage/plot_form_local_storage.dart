import 'package:digital_shores/app/presentation/pages/plot/models/plot_form_data.dart';
import 'package:digital_shores/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class PlotFormLocalStorage {
  PlotFormLocalStorage({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  final DatabaseHelper _databaseHelper;

  Future<void> saveForm(PlotFormData form) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'plot_forms',
      form.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PlotFormData?> getFormByPlotId(String plotId) async {
    final db = await _databaseHelper.database;
    final forms = await db.query(
      'plot_forms',
      where: 'plot_id = ?',
      whereArgs: [plotId],
      limit: 1,
    );

    if (forms.isEmpty) {
      return null;
    }

    return PlotFormData.fromMap(forms.first);
  }

  Future<void> updateFormSyncStatus({
    required String plotId,
    required bool isSynced,
  }) async {
    final db = await _databaseHelper.database;
    await db.update(
      'plot_forms',
      {
        'is_synced': isSynced ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'plot_id = ?',
      whereArgs: [plotId],
    );
  }
}
