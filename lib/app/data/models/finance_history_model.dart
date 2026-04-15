import 'package:digital_shores/app/domain/entities/finance_history.dart';
import 'package:json_annotation/json_annotation.dart';
/*
this class are used for storing history of finance.
when finances are created or updated, add the id as key and the value as the action, either 'created' or 'deleted'
*/

part 'finance_history_model.g.dart';

@JsonSerializable()
class FinanceHistoryModel {
  final Map<String, String> history;

  factory FinanceHistoryModel.fromJson(Map<String, dynamic> json) => _$FinanceHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$FinanceHistoryModelToJson(this);

  FinanceHistoryModel({required this.history});

  factory FinanceHistoryModel.fromEntity(FinanceHistory entity) => FinanceHistoryModel(
        history: entity.history,
      );

  FinanceHistory toEntity() => FinanceHistory(
        history: history,
      );
}