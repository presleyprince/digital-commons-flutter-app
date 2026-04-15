import 'package:digital_shores/app/domain/entities/user_data.dart';
import 'package:digital_shores/app/domain/repositories/auth_repository.dart';
import 'package:digital_shores/core/utils/notifier_state.dart';
import 'package:flutter/material.dart';

class LoginNotifier extends ChangeNotifier {
  // state
  NotifierState<UserData> state = NotifierState();

  // form
  late TextEditingController phoneNumberController;
  late TextEditingController pinController;
  late GlobalKey<FormState> formKey;

  final AuthRepository repository;

  LoginNotifier({required this.repository});

  void init() {
    final phoneNumber = repository.getPhoneNumber();
    phoneNumberController = TextEditingController(text: phoneNumber ?? '');
    pinController = TextEditingController();
    formKey = GlobalKey<FormState>();
  }

  void reset() {
    phoneNumberController.dispose();
    pinController.dispose();
    formKey.currentState?.reset();
    state.reset();
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      state.setLoading();
      notifyListeners();

      final result = await repository.logIn(
        phoneNumber: phoneNumberController.text,
        pin: pinController.text,
      );

      result.fold(
        (failure) {
          state.setError(failure: failure);
          notifyListeners();
          Future.delayed(const Duration(seconds: 1), () => state.setInitial());
        },
        (userData) {
          state.setSuccess(value: userData);
          notifyListeners();
        },
      );
    }
  }
}
