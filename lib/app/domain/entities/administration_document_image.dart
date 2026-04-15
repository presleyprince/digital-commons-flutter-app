class AdministrationDocumentImage {
  final String id;
  final String documentId;
  final String localPath;
  final String? cloudUrl;
  final bool isSynced;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? deletedAt;

  const AdministrationDocumentImage({
    required this.id,
    required this.documentId,
    required this.localPath,
    this.cloudUrl,
    this.isSynced = false,
    this.isDeleted = false,
    required this.createdAt,
    this.deletedAt,
  });

  AdministrationDocumentImage copyWith({
    String? id,
    String? documentId,
    String? localPath,
    String? cloudUrl,
    bool? isSynced,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return AdministrationDocumentImage(
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
