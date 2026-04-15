import 'package:digital_shores/app/domain/entities/administration_document_image.dart';
import 'package:json_annotation/json_annotation.dart';

part 'administration_document_image_model.g.dart';

@JsonSerializable()
class AdministrationDocumentImageModel {
  final String id;
  @JsonKey(name: 'document_id')
  final String documentId;
  @JsonKey(name: 'local_path')
  final String? localPath;
  @JsonKey(name: 'cloud_url')
  final String? cloudUrl;
  @JsonKey(name: 'is_synced')
  final int isSynced;
  @JsonKey(name: 'is_deleted')
  final int isDeleted;
  @JsonKey(name: 'created_at')
  final int createdAt;
  @JsonKey(name: 'deleted_at')
  final int? deletedAt;

  AdministrationDocumentImageModel({
    required this.id,
    required this.documentId,
    required this.localPath,
    this.cloudUrl,
    this.isSynced = 0,
    this.isDeleted = 0,
    required this.createdAt,
    this.deletedAt,
  });

  factory AdministrationDocumentImageModel.fromJson(Map<String, dynamic> json) =>
      _$AdministrationDocumentImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdministrationDocumentImageModelToJson(this);



  AdministrationDocumentImage toEntity() => AdministrationDocumentImage(
        id: id,
        documentId: documentId,
        localPath: localPath!,
        cloudUrl: cloudUrl,
        isSynced: isSynced == 1,
        isDeleted: isDeleted == 1,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
        deletedAt: deletedAt != null ? DateTime.fromMillisecondsSinceEpoch(deletedAt!) : null,
      );

  factory AdministrationDocumentImageModel.fromEntity(AdministrationDocumentImage entity) =>
      AdministrationDocumentImageModel(
        id: entity.id,
        documentId: entity.documentId,
        localPath: entity.localPath,
        cloudUrl: entity.cloudUrl,
        isSynced: entity.isSynced ? 1 : 0,
        isDeleted: entity.isDeleted ? 1 : 0,
        createdAt: entity.createdAt.millisecondsSinceEpoch,
        deletedAt: entity.deletedAt?.millisecondsSinceEpoch,
      );

  AdministrationDocumentImageModel copyWith({
    String? id,
    String? documentId,
    String? localPath,
    String? cloudUrl,
    int? isSynced,
    int? isDeleted,
    int? createdAt,
    int? deletedAt,
  }) {
    return AdministrationDocumentImageModel(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      localPath: localPath ?? this.localPath,
      cloudUrl: cloudUrl ?? this.cloudUrl,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
