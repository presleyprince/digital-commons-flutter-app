import 'package:digital_shores/app/data/models/administration_document_model.dart';
import 'package:digital_shores/core/parameters/administration_parameters.dart';

abstract class AdministrationRemoteDataSource {
  // Future<AdministrationDocumentModel> addDocument(AddDocumentParameter params);
  // Future<AdministrationDocumentModel> updateDocument(UpdateDocumentParameter params);
  // Future<AdministrationDocumentModel> deleteDocument(String id);
  Future<List<AdministrationDocumentModel>> getDocuments(GetDocumentsParameter params);
  // Future<String> uploadImage(File imageFile, String userId);
  // Future<void> deleteImage(String cloudUrl);
  Future<List<AdministrationDocumentModel>> syncDocuments(SyncDocumentsParameter params);
}
