// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'administration_document_image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdministrationDocumentImageModel _$AdministrationDocumentImageModelFromJson(
        Map<String, dynamic> json) =>
    AdministrationDocumentImageModel(
      id: json['id'] as String,
      documentId: json['document_id'] as String,
      localPath: json['local_path'] as String?,
      cloudUrl: json['cloud_url'] as String?,
      isSynced: (json['is_synced'] as num?)?.toInt() ?? 0,
      isDeleted: (json['is_deleted'] as num?)?.toInt() ?? 0,
      createdAt: (json['created_at'] as num).toInt(),
      deletedAt: (json['deleted_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AdministrationDocumentImageModelToJson(
        AdministrationDocumentImageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'document_id': instance.documentId,
      'local_path': instance.localPath,
      'cloud_url': instance.cloudUrl,
      'is_synced': instance.isSynced,
      'is_deleted': instance.isDeleted,
      'created_at': instance.createdAt,
      'deleted_at': instance.deletedAt,
    };
