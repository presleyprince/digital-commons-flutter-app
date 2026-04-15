import 'package:digital_shores/app/data/models/finance_log_model.dart';
import 'package:digital_shores/core/parameters/finance_parameters.dart';

abstract class FinanceRemoteDataSource {
  Future<FinanceLogModel> addFinanceLog(AddFinanceLogParameter parameter);
  Future<FinanceLogModel> updateFinanceLog(UpdateFinanceLogParameter parameter);
  Future<void> syncFinanceLogs(SyncFinanceLogsParameter parameter);
  Future<FinanceLogModel> deleteFinanceLog(DeleteFinanceLogParameter parameter);
  Future<List<FinanceLogModel>> getFinanceLogs(GetFinanceLogsParameter parameter);
}
