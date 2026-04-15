import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/administration/administration_local_data_source.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/administration/administration_remote_data_source.dart';
import 'package:digital_shores/app/data/models/administration_document_image_model.dart';
import 'package:digital_shores/app/data/models/administration_document_model.dart';
import 'package:digital_shores/app/domain/entities/administration_document.dart';
import 'package:digital_shores/app/domain/entities/administration_document_image.dart';
import 'package:digital_shores/app/domain/repositories/administration_repository.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/exception.dart';
import 'package:digital_shores/core/failure.dart';
import 'package:digital_shores/core/parameters/administration_parameters.dart';

class AdministrationRepositoryImpl extends AdministrationRepository {
  final AdministrationLocalDataSource localDataSource;
  final AdministrationRemoteDataSource remoteDataSource;

  AdministrationRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, AdministrationDocument>> addDocumentToLocal(
      {required DocumentType type,
      required String? customType,
      required List<DocumentRequirement> requirements,
      required List<File> images}) async {
    try {
      final document = await localDataSource.addDocumentToLocal(AddDocumentToLocalParameter(
        type: type.index,
        customType: customType,
        requirements: requirements.map((e) => e.index).toList(),
        images: images,
      ));

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
  Future<void> cacheDocumentsToLocal({required List<AdministrationDocument> documents}) async {
    await localDataSource.cacheDocumentsToLocal(CacheDocumentsToLocalParameter(
        documents: documents.map((e) => AdministrationDocumentModel.fromEntity(e)).toList()));
  }

  @override
  Future<void> clearDocumentsFromLocal() async {
    await localDataSource.clearDocumentsFromLocal();
  }

  @override
  Future<Either<Failure, AdministrationDocument>> deleteDocumentFromLocal(
      {required String id}) async {
    try {
      final document =
          await localDataSource.deleteDocumentFromLocal(DeleteDocumentFromLocalParameter(
        id: id,
      ));

      return Right(document.toEntity());
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
  Future<Either<Failure, List<AdministrationDocument>>> getDocuments(
      {required String userId}) async {
    try {
      final documents = await remoteDataSource.getDocuments(GetDocumentsParameter(userId: userId));

      final cachedDocuments = await localDataSource.cacheDocumentsToLocal(
        CacheDocumentsToLocalParameter(documents: documents),
      );
      return Right(cachedDocuments.map((e) => e.toEntity()).toList());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal mengambil data',
          message: e.message,
        ),
      );
    } on Exception catch (e) {
      return Left(BadRequestFailure(
        title: 'Gagal mengambil data',
        message: e.toString(),
      ));
    }
  }

  @override
  Future<List<AdministrationDocument>> getDocumentsFromLocal({
    bool includeDeleted = false,
  }) async {
    final documents = await localDataSource
        .getDocumentsFromLocal(GetDocumentsFromLocalParameter(includeDeleted: includeDeleted));

    return documents.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Either<Failure, List<AdministrationDocument>>> syncDocuments(
      {required List<AdministrationDocument> documents}) async {
    try {
      // check if can sync
      final canSync = await localDataSource.canSyncDocumentsToLocal();

      if (!canSync) {
        return Left(
          BadRequestFailure(
            title: 'Gagal menyinkronkan data',
            message: 'Seluruh data sudah disinkronkan',
          ),
        );
      }

      final localDocuments = await localDataSource
          .getDocumentsFromLocal(GetDocumentsFromLocalParameter(includeDeleted: true));

      final newDocuments = await remoteDataSource.syncDocuments(SyncDocumentsParameter(
        documents: localDocuments,
      ));

      final syncedDocuments =
          await localDataSource.syncDocumentsToLocal(SyncDocumentsToLocalParameter(
        documents: newDocuments,
      ));

      return Right(syncedDocuments.map((e) => e.toEntity()).toList());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal menyinkronkan data',
          message: e.message,
        ),
      );
    } on Exception catch (e) {
      return Left(BadRequestFailure(
        title: 'Gagal menyinkronkan data',
        message: e.toString(),
      ));
    }
  }

  @override
  Future<List<AdministrationDocument>> syncDocumentsToLocal({
    required List<AdministrationDocument> documents,
  }) async {
    final newDocuments = await localDataSource.syncDocumentsToLocal(SyncDocumentsToLocalParameter(
      documents: documents.map((e) => AdministrationDocumentModel.fromEntity(e)).toList(),
    ));

    return newDocuments.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Either<Failure, AdministrationDocument>> updateDocumentFromLocal({
    required String id,
    required DocumentType type,
    required String? customType,
    required List<DocumentRequirement> requirements,
    required bool documentUpdated,
    required List<AdministrationDocumentImage> images,
    required List<File> newImages,
  }) async {
    try {
      final document =
          await localDataSource.updateDocumentFromLocal(UpdateDocumentFromLocalParameter(
        id: id,
        type: type.index,
        customType: customType,
        requirements: requirements.map((e) => e.index).toList(),
        documentUpdated: documentUpdated,
        images: images.map((e) => AdministrationDocumentImageModel.fromEntity(e)).toList(),
        newImages: newImages,
      ));

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
}
