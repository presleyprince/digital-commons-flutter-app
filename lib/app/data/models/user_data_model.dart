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
  @JsonKey(name: 'isAdmin') // fixed to match firebase field
  final bool? isAdmin;
  @JsonKey(name: 'role') // added role, flutter will look for a field called role in the firebase (saved as number 1)
  final int? role;

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
    this.role, // added so Userdatamodle object can optionally pass the role value, has to be listed in the constructor otherwise cant be set
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
        role: role != null ? UserRole.values[role!] : UserRole.user, // added so that if the role number exists in the firebase it it will be converted to match the enum value, otherwise keep it default to UserRole.user (if fire has 1 become secretary)
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
        role: entity.role?.index, // converts enum back to a number to be saved in the firebase. UserRole.Secretary becomes 1
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
    int? role, // make sure copyWith can optionally update the role, it lets us create a copy of the object if fields have changed, role has to be listed like the others
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
      role: role ?? this.role, // use the new role if one was provided, otherwise use the existing role value, ?? if the left side is null use the right side
    );
  }
}
