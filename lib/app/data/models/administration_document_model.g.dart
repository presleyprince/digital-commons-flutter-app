// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'administration_document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdministrationDocumentModel _$AdministrationDocumentModelFromJson(
        Map<String, dynamic> json) =>
    AdministrationDocumentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: (json['type'] as num).toInt(),
      customType: json['custom_type'] as String?,
      requirements: (json['requirements'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      images: (json['images'] as List<dynamic>)
          .map((e) => AdministrationDocumentImageModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      createdAt: (json['created_at'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
      isSynced: (json['is_synced'] as num?)?.toInt() ?? 0,
      isDeleted: (json['is_deleted'] as num?)?.toInt() ?? 0,
      deletedAt: (json['deleted_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AdministrationDocumentModelToJson(
        AdministrationDocumentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': instance.type,
      'custom_type': instance.customType,
      'requirements': instance.requirements,
      'images': AdministrationDocumentModel._imagesToJson(instance.images),
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'is_synced': instance.isSynced,
      'is_deleted': instance.isDeleted,
      'deleted_at': instance.deletedAt,
    };
