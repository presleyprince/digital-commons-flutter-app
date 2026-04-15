import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:digital_shores/app/domain/entities/information.dart';
import 'package:digital_shores/core/failure.dart';

abstract class InformationRepository {
  // remote
  Future<Either<Failure, List<Information>>> getInformations();
  Future<Either<Failure, Information>> getInformationById({required String id});
  Future<Either<Failure, Information>> addInformation({
    required String title,
    required File image,
    required String content,
    required String authorId,
    required String authorName,
    required int category,
  });
  Future<Either<Failure, Information>> updateInformation({
    required String id,
    required String? title,
    required File? image,
    required String? content,
    required String? authorId,
    required int? category,
    required Information oldInformation,
  });
  Future<Either<Failure, Information>> deleteInformation({required Information information});
  Future<Either<Failure, List<Information>>> syncInformations();

  // local
  Future<List<Information>> getInformationsFromLocal();
  Future<void> cacheInformationsToLocal({required List<Information> informations});
  Future<void> clearInformationsFromLocal();
  Future<List<Information>> updateInformationsFromLocal({required List<Information> informations});
  Future<List<Information>> syncInformationsToLocal(
      {required final List<Information> informations});
}
