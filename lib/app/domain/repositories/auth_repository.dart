import 'package:dartz/dartz.dart';
import 'package:digital_shores/app/domain/entities/user_data.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/failure.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserData>> logIn({
    required String phoneNumber,
    required String pin,
  });
  Future<Either<Failure, void>> registerPhoneNumber({
    required final String phoneNumber,
    required final void Function(PhoneAuthCredential credential) verificationCompleted,
    required final void Function(FirebaseAuthException e) verificationFailed,
    required final void Function(String verificationId, int? resendToken) codeSent,
    required final void Function(String verificationId) codeAutoRetrievalTimeout,
    required final int? forceResendingToken,
  });
  Future<Either<Failure, UserData>> verifyOtp({
    required PhoneAuthCredential credential,
    String? fullName,
  });
  Future<Either<Failure, UserData>> signUp({
    required String fullName,
    required String phoneNumber,
    required String pin,
  });
  Future<Either<Failure, void>> logOut();
  Future<Either<Failure, UserData>> updateProfile({
    required String userId,
    required String fullName,
    required String phoneNumber,
    required Occupation? occupation,
    required String? address,
    required String? groupName,
    required String? instructorName,
  });
  Future<Either<Failure, void>> deleteAccount({
    required String userId,
    required String pin,
  });
  Future<Either<Failure, void>> deleteAccountOtp({
    required PhoneAuthCredential credential,
  });

  Future<void> cacheToLocal({required UserData userData});
  UserData? getFromLocal();
  Future<void> removeFromLocal();
  String? getPhoneNumber();
}
