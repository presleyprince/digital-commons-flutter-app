import 'dart:io';

import 'package:digital_shores/app/data/models/administration_document_image_model.dart';
import 'package:digital_shores/app/data/models/administration_document_model.dart';

// remote
class SyncDocumentsParameter {
  final List<AdministrationDocumentModel> documents;

  SyncDocumentsParameter({
    required this.documents,
  });
}

class GetDocumentsParameter {
  final String userId;

  GetDocumentsParameter({
    required this.userId,
  });
}

// local
class AddDocumentToLocalParameter {
  final int type;
  final String? customType;
  final List<int> requirements;
  final List<File> images;

  AddDocumentToLocalParameter({
    required this.type,
    required this.customType,
    required this.requirements,
    required this.images,
  });
}

class CacheDocumentsToLocalParameter {
  final List<AdministrationDocumentModel> documents;

  CacheDocumentsToLocalParameter({
    required this.documents,
  });
}

class UpdateDocumentFromLocalParameter {
  final String id;
  final int type;
  final String? customType;
  final List<int> requirements;
  final bool documentUpdated;
  final List<AdministrationDocumentImageModel> images;
  final List<File> newImages;

  UpdateDocumentFromLocalParameter({
    required this.id,
    required this.type,
    required this.customType,
    required this.requirements,
    required this.documentUpdated,
    required this.images,
    required this.newImages,
  });
}

class DeleteDocumentFromLocalParameter {
  final String id;

  DeleteDocumentFromLocalParameter({
    required this.id,
  });
}

class SyncDocumentsToLocalParameter {
  final List<AdministrationDocumentModel> documents;

  SyncDocumentsToLocalParameter({
    required this.documents,
  });
}

class GetDocumentsFromLocalParameter {
  final bool includeDeleted;

  GetDocumentsFromLocalParameter({
    required this.includeDeleted,
  });
}
