import 'package:digital_shores/app/domain/entities/administration_document_image.dart';
import 'package:digital_shores/core/enums.dart';

class AdministrationDocument {
  final String id;
  final DocumentType type;
  final String? customType;
  final List<DocumentRequirement> requirements;
  final List<AdministrationDocumentImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final String userId;
  final bool isDeleted;
  final DateTime? deletedAt;

  const AdministrationDocument({
    required this.id,
    required this.type,
    this.customType,
    required this.requirements,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.isSynced = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  AdministrationDocument copyWith({
    String? id,
    DocumentType? type,
    String? customType,
    List<DocumentRequirement>? requirements,
    List<AdministrationDocumentImage>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? userId,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return AdministrationDocument(
      id: id ?? this.id,
      type: type ?? this.type,
      customType: customType ?? this.customType,
      requirements: requirements ?? this.requirements,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
