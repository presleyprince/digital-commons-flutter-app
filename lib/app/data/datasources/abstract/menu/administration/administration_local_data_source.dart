import 'package:digital_shores/app/data/models/administration_document_model.dart';
import 'package:digital_shores/core/parameters/administration_parameters.dart';

abstract class AdministrationLocalDataSource {
  Future<AdministrationDocumentModel> addDocumentToLocal(AddDocumentToLocalParameter params);
  Future<AdministrationDocumentModel> updateDocumentFromLocal(UpdateDocumentFromLocalParameter params);
  Future<AdministrationDocumentModel> deleteDocumentFromLocal(DeleteDocumentFromLocalParameter params);
  Future<List<AdministrationDocumentModel>> cacheDocumentsToLocal(CacheDocumentsToLocalParameter params);
  Future<List<AdministrationDocumentModel>> getDocumentsFromLocal(GetDocumentsFromLocalParameter params);
  Future<void> clearDocumentsFromLocal();
  Future<List<AdministrationDocumentModel>> syncDocumentsToLocal(SyncDocumentsToLocalParameter params);

  Future<bool> canSyncDocumentsToLocal();
}