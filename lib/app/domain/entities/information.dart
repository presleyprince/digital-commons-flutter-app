import 'package:digital_shores/core/enums.dart';
import 'package:flutter_quill/flutter_quill.dart';

class Information {
  final String id;
  final String title;
  final String imageUrl;
  final Document content;
  final String author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final InformationCategory category;

  Information({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.category,
  });

  Information copyWith({
    String? id,
    String? title,
    String? imageUrl,
    Document? content,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    InformationCategory? category,
  }) {
    return Information(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      category: category ?? this.category,
    );
  }
}
