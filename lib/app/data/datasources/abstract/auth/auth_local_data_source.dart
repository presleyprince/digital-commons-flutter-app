import 'package:digital_shores/app/data/models/user_data_model.dart';
import 'package:digital_shores/core/parameters/auth_parameter.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToLocal(CacheUserToLocalParameter parameter);
  UserDataModel? getFromLocal();
  Future<void> removeFromLocal(RemoveFromLocalParameter parameter);
  String? getPhoneNumber();
}
