import 'package:digital_shores/app/domain/entities/user_data.dart';
import 'package:digital_shores/app/domain/repositories/auth_repository.dart';
import 'package:digital_shores/core/utils/notifier_state.dart';
import 'package:flutter/material.dart';

class SignupNotifier extends ChangeNotifier {
  // state
  NotifierState<UserData> state = NotifierState();

  // form
  late TextEditingController fullNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController pinController;
  late GlobalKey<FormState> formKey;

  final AuthRepository repository;

  SignupNotifier({required this.repository});

  void init() {
    fullNameController = TextEditingController();
    phoneNumberController = TextEditingController();
    pinController = TextEditingController();
    formKey = GlobalKey<FormState>();
  }

  void reset() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    pinController.dispose();
    formKey.currentState?.reset();
    state.reset();
  }

  Future<void> signup() async {
    if (formKey.currentState!.validate()) {
      state.setLoading();
      notifyListeners();

      final result = await repository.signUp(
        fullName: fullNameController.text,
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
