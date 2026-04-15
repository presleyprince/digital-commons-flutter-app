import 'package:digital_shores/core/enums.dart';

class UserData {
  final String id;
  final String fullName;
  final String phoneNumber;
  final Occupation? occupation;
  final String? address;
  final String? groupName;
  final String? instructorName;
  final bool isAdmin;

  UserData({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.occupation,
    this.address,
    this.groupName,
    this.instructorName,
    required this.isAdmin,
  });
}
