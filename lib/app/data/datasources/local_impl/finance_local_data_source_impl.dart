import 'package:digital_shores/app/data/datasources/abstract/menu/finance/finance_local_data_source.dart';
import 'package:digital_shores/app/data/models/finance_history_model.dart';
import 'package:digital_shores/app/data/models/finance_log_model.dart';
import 'package:digital_shores/core/database/database_helper.dart';
import 'package:digital_shores/core/parameters/finance_parameters.dart';
import 'package:digital_shores/core/utils/generate_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class FinanceLocalDataSourceImpl extends FinanceLocalDataSource {
  final DatabaseHelper _databaseHelper;
  final SharedPreferences _sharedPreferences;

  FinanceLocalDataSourceImpl(
      {required DatabaseHelper databaseHelper, required SharedPreferences sharedPreferences})
      : _databaseHelper = databaseHelper,
        _sharedPreferences = sharedPreferences;

  @override
  Future<FinanceLogModel> addFinanceLogToLocal(AddFinanceLogToLocalParameter parameter) async {
    final db = await _databaseHelper.database;
    final userId = _sharedPreferences.getString('user_id')!;
    final log = FinanceLogModel(
      id: GenerateId.generateNewId(),
      userId: userId,
      amount: parameter.amount,
      description: parameter.description,
      date: parameter.date,
      category: parameter.category,
    );

    final json = log.toJson();

    // json.remove('user_id');
    await db.insert(
      'finance_logs',
      json,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // update finance history table
    await db.insert(
      'finance_history',
      {
        'id': log.id,
        'action': 'created',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return log;
  }

  @override
  Future<void> cacheFinanceLogsToLocal(CacheFinanceLogsToLocalParameter parameter) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();

    for (final log in parameter.financeLogs) {
      final json = log.toJson();
      batch.insert(
        'finance_logs',
        json,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  @override
  Future<void> clearFinanceLogsFromLocal() async {
    final db = await _databaseHelper.database;
    await db.delete('finance_logs');
  }

  @override
  Future<FinanceLogModel> deleteFinanceLogFromLocal(
      DeleteFinanceLogFromLocalParameter parameter) async {
    final db = await _databaseHelper.database;

    // get the row
    final row = await db.query(
      'finance_logs',
      where: 'id = ?',
      whereArgs: [parameter.id],
    );

    // delete row if it exists
    if (row.isNotEmpty) {
      await db.delete(
        'finance_logs',
        where: 'id = ?',
        whereArgs: [parameter.id],
      );
    }

    // update the finance history table
    await db.insert(
      'finance_history',
      {
        'id': parameter.id,
        'action': 'deleted',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // return the row as a FinanceLogModel
    return FinanceLogModel.fromJson(row.first);
  }

  @override
  Future<List<FinanceLogModel>> getFinanceLogsFromLocal() async {
    final db = await _databaseHelper.database;
    final rows = await db.query('finance_logs');
    return rows.map((row) => FinanceLogModel.fromJson(row)).toList();
  }

  @override
  Future<FinanceLogModel> updateFinanceLogFromLocal(
      UpdateFinanceLogFromLocalParameter parameter) async {
    final db = await _databaseHelper.database;
    final log = FinanceLogModel(
      id: parameter.id,
      userId: _sharedPreferences.getString('user_id')!,
      amount: parameter.amount,
      description: parameter.description,
      date: parameter.date,
      category: parameter.category,
    );

    final json = log.toJson();

    // json.remove('user_id');
    await db.update(
      'finance_logs',
      json,
      where: 'id = ?',
      whereArgs: [parameter.id],
    );

    // update finance history table
    await db.insert(
      'finance_history',
      {
        'id': log.id,
        'action': 'created',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return log;
  }

  @override
  Future<FinanceHistoryModel> getFinanceHistoryFromLocal() async {
    final db = await _databaseHelper.database;
    final rows = await db.query('finance_history');
    return FinanceHistoryModel(
      history: Map.fromEntries(
        rows.map(
          (row) => MapEntry(row['id'] as String, row['action'] as String),
        ),
      ),
    );
  }

  @override
  Future<void> clearFinanceHistoryFromLocal() async {
    final db = await _databaseHelper.database;
    await db.delete('finance_history');
  }
}
