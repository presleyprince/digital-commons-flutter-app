// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDataModel _$UserDataModelFromJson(Map<String, dynamic> json) =>
    UserDataModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      occupation: (json['occupation'] as num?)?.toInt(),
      address: json['address'] as String?,
      groupName: json['group_name'] as String?,
      instructorName: json['instructor_name'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
    );

Map<String, dynamic> _$UserDataModelToJson(UserDataModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
      'occupation': instance.occupation,
      'address': instance.address,
      'group_name': instance.groupName,
      'instructor_name': instance.instructorName,
      'isAdmin': instance.isAdmin,
    };
