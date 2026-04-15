import 'package:dartz/dartz.dart';
import 'package:digital_shores/app/domain/entities/finance_log.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/failure.dart';

abstract class FinanceRepository {
  Future<Either<Failure, FinanceLog>> addFinanceLog({
    required int amount,
    required String description,
    required DateTime date,
    required FinanceLogCategory category,
  });
  Future<Either<Failure, FinanceLog>> updateFinanceLog({
    required String id,
    required int amount,
    required String description,
    required DateTime date,
    required FinanceLogCategory category,
    required String userId,
  });
  Future<Either<Failure, void>> syncFinanceLogs();
  Future<Either<Failure, FinanceLog>> deleteFinanceLog({required String id});
  Future<Either<Failure, List<FinanceLog>>> getFinanceLogs({required String userId});

  // local
  Future<Either<Failure, FinanceLog>> addFinanceLogToLocal({
    required int amount,
    required String description,
    required DateTime date,
    required FinanceLogCategory category,
  });
  Future<Either<Failure, FinanceLog>> updateFinanceLogFromLocal({
    required String id,
    required int amount,
    required String description,
    required DateTime date,
    required FinanceLogCategory category,
  });
  Future<Either<Failure, FinanceLog>> deleteFinanceLogFromLocal({required String id});
  Future<void> cacheFinanceLogsToLocal(List<FinanceLog> financeLogList);
  Future<List<FinanceLog>> getFinanceLogsFromLocal();
  Future<void> clearFinanceLogsFromLocal();
}
