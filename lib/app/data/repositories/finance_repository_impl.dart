import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/finance/finance_local_data_source.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/finance/finance_remote_data_source.dart';
import 'package:digital_shores/app/data/models/finance_log_model.dart';
import 'package:digital_shores/app/domain/entities/finance_log.dart';
import 'package:digital_shores/app/domain/repositories/finance_repository.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/exception.dart';
import 'package:digital_shores/core/failure.dart';
import 'package:digital_shores/core/parameters/finance_parameters.dart';
import 'package:http/http.dart';

class FinanceRepositoryImpl extends FinanceRepository {
  final FinanceRemoteDataSource remoteDataSource;
  final FinanceLocalDataSource localDataSource;

  FinanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, FinanceLog>> addFinanceLog({
    required int amount,
    required String description,
    required DateTime date,
    required FinanceLogCategory category,
  }) async {
    try {
      final userData = await remoteDataSource.addFinanceLog(
        AddFinanceLogParameter(
          amount: amount,
          description: description,
          date: date.millisecondsSinceEpoch,
          category: category.index,
        ),
      );
      await localDataSource.addFinanceLogToLocal(
        AddFinanceLogToLocalParameter(
          amount: amount,
          description: description,
          date: date.millisecondsSinceEpoch,
          category: category.index,
        ),
      );
      return Right(userData.toEntity());
    } on SocketException {
      return Left(ConnectionFailure());
    } on HandshakeException {
      return Left(ConnectionFailure());
    } on ClientException {
      return Left(ConnectionFailure());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal mengupdate profile',
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, FinanceLog>> addFinanceLogToLocal({
    required int amount,
    required String description,
    required DateTime date,
    required FinanceLogCategory category,
  }) async {
    try {
      final userData = await localDataSource.addFinanceLogToLocal(
        AddFinanceLogToLocalParameter(
          amount: amount,
          description: description,
          date: date.millisecondsSinceEpoch,
          category: category.index,
        ),
      );
      return Right(userData.toEntity());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal menambahkan data',
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<void> cacheFinanceLogsToLocal(List<FinanceLog> financeLogList) async {
    await localDataSource.cacheFinanceLogsToLocal(
      CacheFinanceLogsToLocalParameter(
          financeLogs: financeLogList.map((e) => FinanceLogModel.fromEntity(e)).toList()),
    );
  }

  @override
  Future<void> clearFinanceLogsFromLocal() async {
    await localDataSource.clearFinanceLogsFromLocal();
  }

  @override
  Future<Either<Failure, FinanceLog>> deleteFinanceLog({required String id}) async {
    try {
      final userData = await remoteDataSource.deleteFinanceLog(
        DeleteFinanceLogParameter(id: id),
      );
      await localDataSource.deleteFinanceLogFromLocal(
        DeleteFinanceLogFromLocalParameter(id: id),
      );
      return Right(userData.toEntity());
    } on SocketException {
      return Left(ConnectionFailure());
    } on HandshakeException {
      return Left(ConnectionFailure());
    } on ClientException {
      return Left(ConnectionFailure());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal mengupdate profile',
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, FinanceLog>> deleteFinanceLogFromLocal({required String id}) async {
    try {
      final userData = await localDataSource.deleteFinanceLogFromLocal(
        DeleteFinanceLogFromLocalParameter(id: id),
      );
      return Right(userData.toEntity());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal menghapus data',
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<FinanceLog>>> getFinanceLogs({required String userId}) async {
    try {
      final userData = await remoteDataSource.getFinanceLogs(
        GetFinanceLogsParameter(userId: userId),
      );
      await localDataSource.cacheFinanceLogsToLocal(
        CacheFinanceLogsToLocalParameter(financeLogs: userData),
      );
      return Right(userData.map((e) => e.toEntity()).toList());
    } on SocketException {
      return Left(ConnectionFailure());
    } on HandshakeException {
      return Left(ConnectionFailure());
    } on ClientException {
      return Left(ConnectionFailure());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal mengupdate profile',
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<List<FinanceLog>> getFinanceLogsFromLocal() async {
    final data = await localDataSource.getFinanceLogsFromLocal();
    return data.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Either<Failure, void>> syncFinanceLogs() async {
    try {
      final financeHistory = await localDataSource.getFinanceHistoryFromLocal();
      final financeLogList = await localDataSource.getFinanceLogsFromLocal();
      if (financeHistory.history.isEmpty) {
        return Left(
          BadRequestFailure(
            title: 'Gagal melakukan sinkronisasi',
            message: 'Seluruh data sudah disinkronkan',
          ),
        );
      }
      await remoteDataSource.syncFinanceLogs(
        SyncFinanceLogsParameter(
          financeLogs: {for (var e in financeLogList) e.id: e},
          financeHistory: financeHistory,
        ),
      );
      await localDataSource.clearFinanceHistoryFromLocal();
      return Right(null);
    } on SocketException {
      return Left(ConnectionFailure());
    } on HandshakeException {
      return Left(ConnectionFailure());
    } on ClientException {
      return Left(ConnectionFailure());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal mengupdate profile',
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, FinanceLog>> updateFinanceLog({
    required String id,
    required int amount,
    required String description,
    required DateTime date,
    required FinanceLogCategory category,
    required String userId,
  }) async {
    try {
      final userData = await remoteDataSource.updateFinanceLog(
        UpdateFinanceLogParameter(
          id: id,
          userId: userId,
          description: description,
          date: date.millisecondsSinceEpoch,
          category: category.index,
          amount: amount,
        ),
      );
      await localDataSource.updateFinanceLogFromLocal(
        UpdateFinanceLogFromLocalParameter(
          id: id,
          amount: amount,
          description: description,
          date: date.millisecondsSinceEpoch,
          category: category.index,
        ),
      );
      return Right(userData.toEntity());
    } on SocketException {
      return Left(ConnectionFailure());
    } on HandshakeException {
      return Left(ConnectionFailure());
    } on ClientException {
      return Left(ConnectionFailure());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal mengupdate profile',
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, FinanceLog>> updateFinanceLogFromLocal(
      {required String id,
      required int amount,
      required String description,
      required DateTime date,
      required FinanceLogCategory category}) async {
    try {
      final userData = await localDataSource.updateFinanceLogFromLocal(
        UpdateFinanceLogFromLocalParameter(
          id: id,
          amount: amount,
          description: description,
          date: date.millisecondsSinceEpoch,
          category: category.index,
        ),
      );
      return Right(userData.toEntity());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal mengupdate data',
          message: e.message,
        ),
      );
    }
  }
}
