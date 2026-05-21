// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'information_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InformationModel _$InformationModelFromJson(Map<String, dynamic> json) =>
    InformationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      category: (json['category'] as num).toInt(),
      createdAt: (json['created_at'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
      isDeleted: (json['is_deleted'] as num?)?.toInt() ?? 0,
      deletedAt: (json['deleted_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$InformationModelToJson(InformationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'image_url': instance.imageUrl,
      'content': instance.content,
      'author': instance.author,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'is_deleted': instance.isDeleted,
      'deleted_at': instance.deletedAt,
      'category': instance.category,
    };
