import 'package:digital_shores/app/domain/entities/user_data.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_data_model.g.dart';

@JsonSerializable()
class UserDataModel {
  final String id;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  final int? occupation;
  final String? address;
  @JsonKey(name: 'group_name')
  final String? groupName;
  @JsonKey(name: 'instructor_name')
  final String? instructorName;
  @JsonKey(name: 'is_admin')
  final bool? isAdmin;

  factory UserDataModel.fromJson(Map<String, dynamic> json) => _$UserDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataModelToJson(this);

  UserDataModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.occupation,
    this.address,
    this.groupName,
    this.instructorName,
    this.isAdmin = false,
  });

  UserData toEntity() => UserData(
        id: id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        occupation: occupation != null ? Occupation.values[occupation!] : null,
        address: address,
        groupName: groupName,
        instructorName: instructorName,
        isAdmin: isAdmin ?? false,
      );

  factory UserDataModel.fromEntity(UserData entity) => UserDataModel(
        id: entity.id,
        fullName: entity.fullName,
        phoneNumber: entity.phoneNumber,
        occupation: entity.occupation?.index,
        address: entity.address,
        groupName: entity.groupName,
        instructorName: entity.instructorName,
        isAdmin: entity.isAdmin,
      );

  UserDataModel copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    int? occupation,
    String? address,
    String? groupName,
    String? instructorName,
    bool? isAdmin,
  }) {
    return UserDataModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      occupation: occupation ?? this.occupation,
      address: address ?? this.address,
      groupName: groupName ?? this.groupName,
      instructorName: instructorName ?? this.instructorName,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
