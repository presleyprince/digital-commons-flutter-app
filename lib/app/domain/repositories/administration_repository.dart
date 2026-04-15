import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:digital_shores/app/domain/entities/administration_document.dart';
import 'package:digital_shores/app/domain/entities/administration_document_image.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/failure.dart';

abstract class AdministrationRepository {
  // Remote operations
  Future<Either<Failure, List<AdministrationDocument>>> getDocuments({
    required String userId,
  });

  Future<Either<Failure, List<AdministrationDocument>>> syncDocuments({
    required List<AdministrationDocument> documents,
  });

  // Local operations
  Future<Either<Failure, AdministrationDocument>> addDocumentToLocal({
    required DocumentType type,
    required String? customType,
    required List<DocumentRequirement> requirements,
    required List<File> images,
  });

  Future<Either<Failure, AdministrationDocument>> updateDocumentFromLocal({
    required String id,
    required DocumentType type,
    required String? customType,
    required List<DocumentRequirement> requirements,
    required bool documentUpdated,
    required List<AdministrationDocumentImage> images,
    required List<File> newImages,
  });

  Future<Either<Failure, AdministrationDocument>> deleteDocumentFromLocal({
    required String id,
  });

  Future<void> cacheDocumentsToLocal({required List<AdministrationDocument> documents});

  Future<List<AdministrationDocument>> getDocumentsFromLocal({bool includeDeleted = false});

  Future<void> clearDocumentsFromLocal();

  Future<List<AdministrationDocument>> syncDocumentsToLocal({
    required List<AdministrationDocument> documents,
  });
}
