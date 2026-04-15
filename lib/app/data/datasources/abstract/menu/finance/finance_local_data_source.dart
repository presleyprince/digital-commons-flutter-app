import 'package:digital_shores/app/data/models/finance_history_model.dart';
import 'package:digital_shores/app/data/models/finance_log_model.dart';
import 'package:digital_shores/core/parameters/finance_parameters.dart';

abstract class FinanceLocalDataSource {
  Future<FinanceLogModel> addFinanceLogToLocal(AddFinanceLogToLocalParameter parameter);
  Future<FinanceLogModel> updateFinanceLogFromLocal(UpdateFinanceLogFromLocalParameter parameter);
  Future<FinanceLogModel> deleteFinanceLogFromLocal(DeleteFinanceLogFromLocalParameter parameter);
  Future<void> cacheFinanceLogsToLocal(CacheFinanceLogsToLocalParameter parameter);
  Future<List<FinanceLogModel>> getFinanceLogsFromLocal();
  Future<void> clearFinanceLogsFromLocal();

  // history
  Future<FinanceHistoryModel> getFinanceHistoryFromLocal();
  Future<void> clearFinanceHistoryFromLocal();
}
