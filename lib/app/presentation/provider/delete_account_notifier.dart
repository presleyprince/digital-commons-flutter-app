import 'dart:async';

import 'package:digital_shores/app/domain/repositories/auth_repository.dart';
import 'package:digital_shores/core/failure.dart';
import 'package:digital_shores/core/utils/notifier_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DeleteAccountNotifier extends ChangeNotifier {
  late TextEditingController otpController;
  late GlobalKey<FormState> formKey;
  late FocusNode otpFocusNode;
  String? phoneNumber;
  Timer? timer;

  NotifierState<void> registerPhoneNumberState = NotifierState();
  NotifierState<void> verifyOtpState = NotifierState();
  NotifierState<void> resendOtpState = NotifierState();

  ValueNotifier<int?> resendOtpTime = ValueNotifier(null);
  String? verificationId;
  int? resendToken;

  final AuthRepository repository;

  DeleteAccountNotifier({required this.repository});

  String obfuscatePhoneNumber() {
    return reformatPhoneNumber(phoneNumber!).replaceRange(3, 8, '*****');
  }

  void init() {
    phoneNumber = repository.getPhoneNumber();
    formKey = GlobalKey<FormState>();
  }

  void reset() {
    formKey.currentState?.reset();
    registerPhoneNumberState.reset();
    phoneNumber = null;
  }

  void initOtp() {
    otpController = TextEditingController();
    otpFocusNode = FocusNode();
  }

  void resetOtp() {
    otpController.dispose();
    verifyOtpState.reset();
    otpFocusNode.dispose();
    resendOtpTime.value = null;
    verificationId = null;
    resendToken = null;
  }

  String reformatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }

    return '+61$phoneNumber';
  }

  Future<void> resendOtp() async {
    resendOtpState.setLoading();
    notifyListeners();

    final result = await repository.registerPhoneNumber(
      phoneNumber: reformatPhoneNumber(phoneNumber!),
      verificationCompleted: verifyOtp,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (verificationId) {},
      forceResendingToken: resendToken,
    );

    result.fold(
      (failure) {
        resendOtpState.setError(failure: failure);
      },
      (value) {
        // resendOtpState.setSuccess();
      },
    );

    notifyListeners();
    Future.delayed(const Duration(seconds: 1), () => resendOtpState.reset());
  }

  Future<void> registerPhoneNumber() async {
    registerPhoneNumberState.setLoading();
    notifyListeners();

    // if phone number has 0 as the first digit, replace it with 62

    await repository.registerPhoneNumber(
      phoneNumber: reformatPhoneNumber(phoneNumber!),
      verificationCompleted: automaticVerifyOtp,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (verificationId) {},
      forceResendingToken: resendToken,
    );
  }

  Future<void> sentOtp() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: otpController.text,
    );

    await verifyOtp(credential);
  }

  Future<void> automaticVerifyOtp(PhoneAuthCredential credential) async {
    if (formKey.currentState!.validate()) {
      verifyOtpState.setLoading();
      notifyListeners();

      final result = await repository.deleteAccountOtp(credential: credential);

      result.fold(
        (_) {
          // do nothing
        },
        (_) {
          verifyOtpState.setSuccess();
          timer?.cancel();
        },
      );

      notifyListeners();
      Future.delayed(const Duration(seconds: 1), () => verifyOtpState.reset());
    }
  }
  
  Future<void> verifyOtp(PhoneAuthCredential credential) async {
    if (formKey.currentState!.validate()) {
      verifyOtpState.setLoading();
      notifyListeners();

      final result = await repository.deleteAccountOtp(credential: credential);

      result.fold(
        (failure) {
          verifyOtpState.setError(failure: failure);
        },
        (_) {
          verifyOtpState.setSuccess();
          timer?.cancel();
        },
      );

      notifyListeners();
      Future.delayed(const Duration(seconds: 1), () => verifyOtpState.reset());
    }
  }

  void verificationFailed(FirebaseAuthException e) {
    final title = 'Terjadi kesalahan';
    late String message;

    if (e.code == 'invalid-phone-number') {
      message = 'Nomor telepon tidak valid';
    } else if (e.code == 'too-many-requests') {
      message = 'Terlalu banyak permintaan. Coba lagi nanti';
    } else {
      message = e.message ?? 'Terjadi kesalahan saat mengirim kode OTP';
    }

    registerPhoneNumberState.setError(
      failure: BadRequestFailure(
        title: title,
        message: message,
      ),
    );

    notifyListeners();
    Future.delayed(const Duration(seconds: 1), () => registerPhoneNumberState.reset());
  }

  void codeSent(String verificationId, int? resendToken) {
    registerPhoneNumberState.setSuccess();
    notifyListeners();
    Future.delayed(const Duration(seconds: 1), () => registerPhoneNumberState.reset());

    this.verificationId = verificationId;
    this.resendToken = resendToken;
    resendOtpTime.value = 60;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendOtpTime.value == 0) {
        timer.cancel();
        resendOtpTime.value = null;
      } else {
        if (resendOtpTime.value != null) {
          resendOtpTime.value = resendOtpTime.value! - 1;
        }
      }
    });
  }
}
