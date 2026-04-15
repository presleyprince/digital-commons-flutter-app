import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:digital_shores/app/data/datasources/abstract/auth/auth_local_data_source.dart';
import 'package:digital_shores/app/data/datasources/abstract/auth/auth_remote_data_source.dart';
import 'package:digital_shores/app/data/models/user_data_model.dart';
import 'package:digital_shores/app/domain/entities/user_data.dart';
import 'package:digital_shores/app/domain/repositories/auth_repository.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/exception.dart';
import 'package:digital_shores/core/failure.dart';
import 'package:digital_shores/core/parameters/auth_parameter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> cacheToLocal({required UserData userData}) async {
    await localDataSource.cacheToLocal(
      CacheUserToLocalParameter(userData: UserDataModel.fromEntity(userData)),
    );
  }

  @override
  Future<Either<Failure, void>> deleteAccount({
    required String userId,
    required String pin,
  }) async {
    try {
      await remoteDataSource.deleteAccount(
        DeleteAccountParameter(
          userId: userId,
          pin: pin,
        ),
      );

      await localDataSource.removeFromLocal(RemoveFromLocalParameter(deletePhoneNumber: true));
      return const Right(null);
    } on SocketException {
      return Left(ConnectionFailure());
    } on HandshakeException {
      return Left(ConnectionFailure());
    } on ClientException {
      return Left(ConnectionFailure());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal menghapus akun',
          message: e.message,
        ),
      );
    }
  }

  @override
  UserData? getFromLocal() {
    return localDataSource.getFromLocal()?.toEntity();
  }

  @override
  Future<Either<Failure, UserData>> logIn({
    required String phoneNumber,
    required String pin,
  }) async {
    try {
      final userData = await remoteDataSource.logIn(
        LogInParameter(
          phoneNumber: phoneNumber,
          pin: pin,
        ),
      );
      await localDataSource.cacheToLocal(
        CacheUserToLocalParameter(userData: userData),
      );
      return Right(userData.toEntity());
    } on SocketException {
      return Left(ConnectionFailure());
    } on HandshakeException {
      return Left(ConnectionFailure());
    } on ClientException {
      return Left(ConnectionFailure());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Login Gagal',
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<void> removeFromLocal() async {
    await localDataSource.removeFromLocal(RemoveFromLocalParameter(deletePhoneNumber: false));
  }

  @override
  Future<Either<Failure, void>> logOut() async {
    try {
      await remoteDataSource.logOut();
      await localDataSource.removeFromLocal(RemoveFromLocalParameter(deletePhoneNumber: false));
      return const Right(null);
    } on SocketException {
      return Left(ConnectionFailure());
    } on HandshakeException {
      return Left(ConnectionFailure());
    } on ClientException {
      return Left(ConnectionFailure());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal keluar',
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserData>> signUp({
    required String fullName,
    required String phoneNumber,
    required String pin,
  }) async {
    try {
      final userData = await remoteDataSource.signUp(
        SignUpParameter(
          fullName: fullName,
          phoneNumber: phoneNumber,
          pin: pin,
        ),
      );
      await localDataSource.cacheToLocal(
        CacheUserToLocalParameter(userData: userData),
      );
      return Right(userData.toEntity());
    } on SocketException {
      return Left(ConnectionFailure());
    } on HandshakeException {
      return Left(ConnectionFailure());
    } on ClientException {
      return Left(ConnectionFailure());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal mendaftar',
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserData>> updateProfile({
    required String userId,
    required String fullName,
    required String phoneNumber,
    required Occupation? occupation,
    required String? address,
    required String? groupName,
    required String? instructorName,
  }) async {
    try {
      final userData = await remoteDataSource.updateProfile(
        UpdateProfileParameter(
          userId: userId,
          fullName: fullName,
          phoneNumber: phoneNumber,
          occupation: occupation?.index,
          address: address,
          groupName: groupName,
          instructorName: instructorName,
        ),
      );
      await localDataSource.cacheToLocal(
        CacheUserToLocalParameter(userData: userData),
      );
      return Right(userData.toEntity());
    } on SocketException {
      return Left(ConnectionFailure());
    } on HandshakeException {
      return Left(ConnectionFailure());
    } on ClientException {
      return Left(ConnectionFailure());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal mengupdate profile',
          message: e.message,
        ),
      );
    }
  }

  @override
  String? getPhoneNumber() {
    return localDataSource.getPhoneNumber();
  }

  @override
  Future<Either<Failure, void>> registerPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential credential) verificationCompleted,
    required void Function(FirebaseAuthException e) verificationFailed,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
    required int? forceResendingToken,
  }) async {
    try {
      await remoteDataSource.registerPhoneNumber(
        RegisterPhoneNumberParameter(
          phoneNumber: phoneNumber,
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
          forceResendingToken: forceResendingToken,
        ),
      );
      return const Right(null);
    } on SocketException {
      return Left(ConnectionFailure());
    } on HandshakeException {
      return Left(ConnectionFailure());
    } on ClientException {
      return Left(ConnectionFailure());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal mendaftarkan nomor telepon',
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserData>> verifyOtp({
    required PhoneAuthCredential credential,
    String? fullName,
  }) async {
    try {
      final userData = await remoteDataSource.verifyOtp(
        VerifyOtpParameter(
          credential: credential,
          fullName: fullName,
        ),
      );
      await localDataSource.cacheToLocal(
        CacheUserToLocalParameter(userData: userData),
      );
      return Right(userData.toEntity());
    } on SocketException {
      return Left(ConnectionFailure());
    } on HandshakeException {
      return Left(ConnectionFailure());
    } on ClientException {
      return Left(ConnectionFailure());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal verifikasi OTP',
          message: e.message,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccountOtp({required PhoneAuthCredential credential}) async {
    try {
      await remoteDataSource.deleteAccountOtp(
        DeleteAccountOtpParameter(
          credential: credential,
        ),
      );
      await localDataSource.removeFromLocal(RemoveFromLocalParameter(deletePhoneNumber: true));
      return const Right(null);
    } on SocketException {
      return Left(ConnectionFailure());
    } on HandshakeException {
      return Left(ConnectionFailure());
    } on ClientException {
      return Left(ConnectionFailure());
    } on CustomException catch (e) {
      return Left(
        BadRequestFailure(
          title: 'Gagal menghapus akun',
          message: e.message,
        ),
      );
    }
  }
}
