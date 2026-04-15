import 'package:digital_shores/app/data/datasources/abstract/menu/information/information_local_data_source.dart';
import 'package:digital_shores/app/data/models/information_model.dart';
import 'package:digital_shores/core/database/database_helper.dart';
import 'package:digital_shores/core/parameters/information_parameters.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class InformationLocalDataSourceImpl extends InformationLocalDataSource {
  final DatabaseHelper _databaseHelper;
  final SharedPreferences _sharedPreferences;

  InformationLocalDataSourceImpl(
      {required DatabaseHelper databaseHelper, required SharedPreferences sharedPreferences})
      : _databaseHelper = databaseHelper, 
        _sharedPreferences = sharedPreferences;

  @override
  Future<void> cacheInformationsToLocal(CacheInformationsToLocalParameter params) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();

    for (final log in params.informations) {
      final json = log.toJson();
      batch.insert(
        'informations',
        json,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  @override
  Future<void> clearInformationsFromLocal() async {
    final db = await _databaseHelper.database;
    await db.delete('informations');
    _sharedPreferences.remove('information_last_sync');
  }

  @override
  Future<List<InformationModel>> getInformationsFromLocal() async {
    final db = await _databaseHelper.database;
    final result = await db.query('informations', orderBy: 'updated_at DESC');
    return result.map((e) => InformationModel.fromJson(e)).toList();
  }

  @override
  Future<List<InformationModel>> updateInformationsFromLocal(
      UpdateInformationsFromLocalParameter params) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();
    for (final log in params.informations) {
      final json = log.toJson();
      batch.update(
        'informations',
        json,
        where: 'id = ?',
        whereArgs: [log.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
    return params.informations;
  }

  @override
  Future<List<InformationModel>> syncInformationsToLocal(
      SyncInformationsToLocalParameter params) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();
    for (final log in params.informations) {
      if (log.isDeleted == 1) {
        batch.delete(
          'informations',
          where: 'id = ?',
          whereArgs: [log.id],
        );
      } else {
        final json = log.toJson();
        // if the id exists, update, else insert
        batch.insert(
          'informations',
          json,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit();

    // update the last sync time
    await _sharedPreferences.setInt(
        'information_last_sync', DateTime.now().toUtc().millisecondsSinceEpoch);

    // return all informations
    return await getInformationsFromLocal();
  }

  @override
  int getInformationLastSync() {
    return _sharedPreferences.getInt('information_last_sync') ?? 0;
  }

  @override
  Future<void> deleteInformationFromLocal(DeleteInformationFromLocalParameter params) async {
    final db = await _databaseHelper.database;

    await db.delete(
      'informations',
      where: 'id == ?',
      whereArgs: [params.id],
    );
  }

  @override
  Future<void> updateInformationLastSync() async {
    await _sharedPreferences.setInt(
        'information_last_sync', DateTime.now().toUtc().millisecondsSinceEpoch);
  }
}
