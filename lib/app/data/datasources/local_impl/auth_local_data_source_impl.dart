import 'dart:convert';

import 'package:digital_shores/app/data/datasources/abstract/auth/auth_local_data_source.dart';
import 'package:digital_shores/app/data/models/user_data_model.dart';
import 'package:digital_shores/core/parameters/auth_parameter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences storage;

  AuthLocalDataSourceImpl({required this.storage});

  @override
  Future<void> cacheToLocal(CacheUserToLocalParameter parameter) async {
    String phoneNumber = parameter.userData.phoneNumber;
    if (phoneNumber.contains('+61')) {
      phoneNumber = phoneNumber.replaceFirst('+61', '');
    }
    await storage.setString('user_id', parameter.userData.id);
    await storage.setString('user', json.encode(parameter.userData.toJson()));
    await storage.setString('phone_number', phoneNumber);
  }

  @override
  UserDataModel? getFromLocal() {
    final user = storage.getString('user');
    if (user != null) {
      return UserDataModel.fromJson(json.decode(user));
    } else {
      return null;
    }
  }

  @override
  Future<void> removeFromLocal(RemoveFromLocalParameter parameter) async {
    await storage.remove('user_id');
    await storage.remove('user');
    if (parameter.deletePhoneNumber) {
      await storage.remove('phone_number');
    }
  }

  @override
  String? getPhoneNumber() {
    return storage.getString('phone_number');
  }
}
