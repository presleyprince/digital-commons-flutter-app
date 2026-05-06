import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/information/information_local_data_source.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/information/information_remote_data_source.dart';
import 'package:digital_shores/app/data/models/information_model.dart';
import 'package:digital_shores/app/domain/entities/information.dart';
import 'package:digital_shores/app/domain/repositories/information_repository.dart';
import 'package:digital_shores/core/exception.dart';
import 'package:digital_shores/core/failure.dart';
import 'package:digital_shores/core/parameters/information_parameters.dart';

class InformationRepositoryImpl extends InformationRepository {
  final InformationLocalDataSource localDataSource;
  final InformationRemoteDataSource remoteDataSource;

  InformationRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Information>> addInformation(
      {required String title,
      File? image, // removed required, dont need image for news as a must
      required String content,
      required String authorId,
      required String authorName,
      required int category}) async {
    try {
      final document = await remoteDataSource.addInformation(AddInformationParameter(
        title: title,
        image: image,
        content: content,
        authorId: authorId,
        authorName: authorName,
        category: category,
      ));

      // add to local
      await localDataSource
          .cacheInformationsToLocal(CacheInformationsToLocalParameter(informations: [document]));

      return Right(document.toEntity());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal menambahkan data',
          message: e.message,
        ),
      );
    } on Exception catch (e) {
      return Left(BadRequestFailure(
        title: 'Gagal menambahkan data',
        message: e.toString(),
      ));
    }
  }

  @override
  Future<void> cacheInformationsToLocal({required List<Information> informations}) async {
    await localDataSource.cacheInformationsToLocal(CacheInformationsToLocalParameter(
        informations: informations.map((e) => InformationModel.fromEntity(e)).toList()));
  }

  @override
  Future<void> clearInformationsFromLocal() async {
    await localDataSource.clearInformationsFromLocal();
  }

  @override
  Future<Either<Failure, Information>> deleteInformation({required Information information}) async {
    try {
      await remoteDataSource.deleteInformation(
          DeleteInformationParameter(information: InformationModel.fromEntity(information)));

      // delete from local
      await localDataSource
          .deleteInformationFromLocal(DeleteInformationFromLocalParameter(id: information.id));
      return Right(information);
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal menghapus data',
          message: e.message,
        ),
      );
    } on Exception catch (e) {
      return Left(BadRequestFailure(
        title: 'Gagal menghapus data',
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, Information>> getInformationById({required String id}) async {
    try {
      final document =
          await remoteDataSource.getInformationById(GetInformationByIdParameter(id: id));

      return Right(document.toEntity());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal mendapatkan data',
          message: e.message,
        ),
      );
    } on Exception catch (e) {
      return Left(BadRequestFailure(
        title: 'Gagal mendapatkan data',
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, List<Information>>> getInformations() async {
    try {
      final lastSync = localDataSource.getInformationLastSync();

      final informations =
          await remoteDataSource.getInformations(GetInformationsParameter(lastSync: lastSync));

      // cache all informations
      await localDataSource
          .cacheInformationsToLocal(CacheInformationsToLocalParameter(informations: informations));

      // update last sync
      await localDataSource.updateInformationLastSync();

      return Right(informations.map((e) => e.toEntity()).toList());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal menambahkan data',
          message: e.message,
        ),
      );
    } on Exception catch (e) {
      return Left(BadRequestFailure(
        title: 'Gagal menambahkan data',
        message: e.toString(),
      ));
    }
  }

  @override
  Future<List<Information>> getInformationsFromLocal() async {
    final informations = await localDataSource.getInformationsFromLocal();
    return informations.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<Information>> syncInformationsToLocal(
      {required List<Information> informations}) async {
    final syncedInformations = await localDataSource.syncInformationsToLocal(
        SyncInformationsToLocalParameter(
            informations: informations.map((e) => InformationModel.fromEntity(e)).toList()));
    return syncedInformations.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Either<Failure, Information>> updateInformation(
      {required String id,
      required String? title,
      required File? image,
      required String? content,
      required String? authorId,
      required int? category,
      required Information oldInformation}) async {
    try {
      final document = await remoteDataSource.updateInformation(UpdateInformationParameter(
        id: id,
        title: title,
        image: image,
        content: content,
        authorId: authorId,
        category: category,
        oldInformation: InformationModel.fromEntity(oldInformation),
      ));

      // update local
      await localDataSource.updateInformationsFromLocal(
          UpdateInformationsFromLocalParameter(informations: [document]));

      return Right(document.toEntity());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal mengupdate data',
          message: e.message,
        ),
      );
    } on Exception catch (e) {
      return Left(BadRequestFailure(
        title: 'Gagal mengupdate data',
        message: e.toString(),
      ));
    }
  }

  @override
  Future<List<Information>> updateInformationsFromLocal(
      {required List<Information> informations}) async {
    final updatedInformations = await localDataSource.updateInformationsFromLocal(
        UpdateInformationsFromLocalParameter(
            informations: informations.map((e) => InformationModel.fromEntity(e)).toList()));
    return updatedInformations.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Either<Failure, List<Information>>> syncInformations() async {
    try {
      final lastSync = localDataSource.getInformationLastSync();

      final informations =
          await remoteDataSource.getInformations(GetInformationsParameter(lastSync: lastSync));

      // cache all informations
      final syncedInformations = await localDataSource
          .syncInformationsToLocal(SyncInformationsToLocalParameter(informations: informations));

      // update last sync
      await localDataSource.updateInformationLastSync();

      return Right(syncedInformations.map((e) => e.toEntity()).toList());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal menambahkan data',
          message: e.message,
        ),
      );
    } on Exception catch (e) {
      return Left(BadRequestFailure(
        title: 'Gagal menambahkan data',
        message: e.toString(),
      ));
    }
  }
}
