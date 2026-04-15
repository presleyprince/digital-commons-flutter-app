// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinanceLogModel _$FinanceLogModelFromJson(Map<String, dynamic> json) =>
    FinanceLogModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toInt(),
      description: json['description'] as String,
      date: (json['date'] as num).toInt(),
      category: (json['category'] as num).toInt(),
      userId: json['user_id'] as String?,
    );

Map<String, dynamic> _$FinanceLogModelToJson(FinanceLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'amount': instance.amount,
      'description': instance.description,
      'date': instance.date,
      'category': instance.category,
    };
