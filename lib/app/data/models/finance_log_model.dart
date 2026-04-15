import 'package:digital_shores/app/domain/entities/finance_log.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'finance_log_model.g.dart';

@JsonSerializable()
class FinanceLogModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String? userId;
  final int amount;
  final String description;
  final int date;
  final int category;

  factory FinanceLogModel.fromJson(Map<String, dynamic> json) => _$FinanceLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$FinanceLogModelToJson(this);

  FinanceLogModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
    this.userId,
  });

  FinanceLog toEntity() => FinanceLog(
        id: id,
        amount: amount,
        description: description,
        date: DateTime.fromMillisecondsSinceEpoch(date),
        category: FinanceLogCategory.values[category],
      );

  factory FinanceLogModel.fromEntity(FinanceLog entity) => FinanceLogModel(
        id: entity.id,
        amount: entity.amount,
        description: entity.description,
        date: entity.date.millisecondsSinceEpoch,
        category: entity.category.index,
      );
}
