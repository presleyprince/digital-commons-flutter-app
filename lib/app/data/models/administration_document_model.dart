import 'package:digital_shores/app/data/models/administration_document_image_model.dart';
import 'package:digital_shores/app/domain/entities/administration_document.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'administration_document_model.g.dart';

@JsonSerializable()
class AdministrationDocumentModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final int type;
  @JsonKey(name: 'custom_type')
  final String? customType;
  final List<int> requirements;
  @JsonKey(toJson: _imagesToJson)
  final List<AdministrationDocumentImageModel> images;
  @JsonKey(name: 'created_at')
  final int createdAt;
  @JsonKey(name: 'updated_at')
  final int updatedAt;
  @JsonKey(name: 'is_synced')
  final int isSynced;
  @JsonKey(name: 'is_deleted')
  final int isDeleted;
  @JsonKey(name: 'deleted_at')
  final int? deletedAt;

  AdministrationDocumentModel({
    required this.id,
    required this.userId,
    required this.type,
    this.customType,
    required this.requirements,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = 0,
    this.isDeleted = 0,
    this.deletedAt,
  });

  factory AdministrationDocumentModel.fromJson(Map<String, dynamic> json) =>
      _$AdministrationDocumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdministrationDocumentModelToJson(this);

  static List<Map<String, dynamic>> _imagesToJson(List<AdministrationDocumentImageModel> images) => images.map((img) => img.toJson()).toList();



  AdministrationDocument toEntity() => AdministrationDocument(
        id: id,
        userId: userId,
        type: DocumentType.values[type],
        customType: customType,
        requirements: requirements.map((req) => DocumentRequirement.values[req]).toList(),
        images: images.map((img) => img.toEntity()).toList(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
        isSynced: isSynced == 1,
        isDeleted: isDeleted == 1,
        deletedAt: deletedAt != null ? DateTime.fromMillisecondsSinceEpoch(deletedAt!) : null,
      );

  factory AdministrationDocumentModel.fromEntity(AdministrationDocument entity) =>
      AdministrationDocumentModel(
        id: entity.id,
        userId: entity.userId,
        type: entity.type.index,
        customType: entity.customType,
        requirements: entity.requirements.map((req) => req.index).toList(),
        images:
            entity.images.map((img) => AdministrationDocumentImageModel.fromEntity(img)).toList(),
        createdAt: entity.createdAt.millisecondsSinceEpoch,
        updatedAt: entity.updatedAt.millisecondsSinceEpoch,
        isSynced: entity.isSynced ? 1 : 0,
        isDeleted: entity.isDeleted ? 1 : 0,
        deletedAt: entity.deletedAt?.millisecondsSinceEpoch,
      );

  AdministrationDocumentModel copyWith({
    String? id,
    String? userId,
    int? type,
    String? customType,
    List<int>? requirements,
    List<AdministrationDocumentImageModel>? images,
    int? createdAt,
    int? updatedAt,
    int? isSynced,
    int? isDeleted,
    int? deletedAt,
  }) {
    return AdministrationDocumentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      customType: customType ?? this.customType,
      requirements: requirements ?? this.requirements,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
