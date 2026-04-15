import 'package:digital_shores/app/data/models/user_data_model.dart';
import 'package:digital_shores/core/parameters/auth_parameter.dart';

abstract class AuthRemoteDataSource {
  Future<UserDataModel> logIn(LogInParameter parameter);
  Future<UserDataModel> signUp(SignUpParameter parameter);
  Future<void> registerPhoneNumber(RegisterPhoneNumberParameter parameter);
  Future<UserDataModel> verifyOtp(VerifyOtpParameter parameter);
  Future<UserDataModel> updateProfile(UpdateProfileParameter parameter);
  Future<void> deleteAccount(DeleteAccountParameter parameter);
  Future<void> deleteAccountOtp(DeleteAccountOtpParameter parameter);
  Future<void> logOut();
}
