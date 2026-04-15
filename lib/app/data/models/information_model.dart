import 'dart:convert';

import 'package:digital_shores/app/domain/entities/information.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:json_annotation/json_annotation.dart';

part 'information_model.g.dart';

@JsonSerializable()
class InformationModel {
  final String id;
  final String title;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  final String content;
  final String author;
  @JsonKey(name: 'created_at')
  final int createdAt;
  @JsonKey(name: 'updated_at')
  final int updatedAt;
  @JsonKey(name: 'is_deleted')
  final int isDeleted;
  @JsonKey(name: 'deleted_at')
  final int? deletedAt;
  final int category;

  InformationModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.content,
    required this.author,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = 0,
    this.deletedAt,
  });

  factory InformationModel.fromJson(Map<String, dynamic> json) => _$InformationModelFromJson(json);

  Map<String, dynamic> toJson() => _$InformationModelToJson(this);

  Information toEntity() {
    return Information(
      id: id,
      title: title,
      imageUrl: imageUrl,
      content: Document.fromJson(jsonDecode(content)),
      author: author,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt).toLocal(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt).toLocal(),
      deletedAt: deletedAt != null ? DateTime.fromMillisecondsSinceEpoch(deletedAt!).toLocal() : null,
      category: InformationCategory.values[category],
    );
  }

  factory InformationModel.fromEntity(Information entity) {
    return InformationModel(
      id: entity.id,
      title: entity.title,
      imageUrl: entity.imageUrl,
      content: jsonEncode(entity.content.toDelta().toJson()),
      author: entity.author,
      createdAt: entity.createdAt.millisecondsSinceEpoch,
      updatedAt: entity.updatedAt.millisecondsSinceEpoch,
      isDeleted: entity.deletedAt != null ? 1 : 0,
      deletedAt: entity.deletedAt?.millisecondsSinceEpoch,
      category: entity.category.index,
    );
  }

  InformationModel copyWith(
   { String? title,
    String? imageUrl,
    String? content,
    String? author,
    int? createdAt,
    int? updatedAt,
    bool? isDeleted,
    int? deletedAt,
    int? category,}
  ) {
    return InformationModel(
      id: id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      content: content ?? this.content,
      author: author ?? this.author,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
