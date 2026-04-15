import 'package:digital_shores/app/data/models/user_data_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPhoneNumberParameter {
  final String phoneNumber;
  final void Function(PhoneAuthCredential credential) verificationCompleted;
  final void Function(FirebaseAuthException e) verificationFailed;
  final void Function(String verificationId, int? resendToken) codeSent;
  final void Function(String verificationId) codeAutoRetrievalTimeout;
  final int? forceResendingToken;

  RegisterPhoneNumberParameter({
    required this.phoneNumber,
    required this.verificationCompleted,
    required this.verificationFailed,
    required this.codeSent,
    required this.codeAutoRetrievalTimeout,
    required this.forceResendingToken,
  });
}

class VerifyOtpParameter {
  final PhoneAuthCredential credential;
  final String? fullName;

  VerifyOtpParameter({
    required this.credential,
    this.fullName,
  });
}

class SignUpParameter {
  final String fullName;
  final String phoneNumber;
  final String pin;

  SignUpParameter({
    required this.fullName,
    required this.phoneNumber,
    required this.pin,
  });
}

class LogInParameter {
  final String phoneNumber;
  final String pin;

  LogInParameter({
    required this.phoneNumber,
    required this.pin,
  });
}

class UpdateProfileParameter {
  final String userId;
  final String fullName;
  final String phoneNumber;
  final int? occupation;
  final String? address;
  final String? groupName;
  final String? instructorName;

  UpdateProfileParameter({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    this.occupation,
    this.address,
    this.groupName,
    this.instructorName,
  });
}

class DeleteAccountParameter {
  final String userId;
  final String pin;

  DeleteAccountParameter({
    required this.userId,
    required this.pin,
  });
}

class DeleteAccountOtpParameter {
  final PhoneAuthCredential credential;

  DeleteAccountOtpParameter({
    required this.credential,
  });
}

class CacheUserToLocalParameter {
  final UserDataModel userData;

  CacheUserToLocalParameter({required this.userData});
}

class RemoveFromLocalParameter {
  final bool deletePhoneNumber;

  RemoveFromLocalParameter({required this.deletePhoneNumber});
}
