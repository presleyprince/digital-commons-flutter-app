import 'package:digital_shores/app/domain/entities/user_data.dart';
import 'package:digital_shores/app/domain/repositories/auth_repository.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/notifier_state.dart';
import 'package:flutter/cupertino.dart';

class AuthNotifier extends ChangeNotifier {
  // form
  late TextEditingController fullNameController;
  late TextEditingController phoneNumberController;
  late ValueNotifier<Occupation?> occupationNotifier;
  late TextEditingController addressController;
  late TextEditingController groupNameController;
  late TextEditingController instructorNameController;
  late GlobalKey<FormState> formKey;

  void initForm() {
    fullNameController = TextEditingController(text: userData?.fullName);
    phoneNumberController = TextEditingController(text: userData?.phoneNumber);
    occupationNotifier = ValueNotifier(userData?.occupation);
    addressController = TextEditingController(text: userData?.address);
    groupNameController = TextEditingController(text: userData?.groupName);
    instructorNameController = TextEditingController(text: userData?.instructorName);
    formKey = GlobalKey<FormState>();
    // updateProfileImageState.reset();
    // updateProfileState.reset();
  }

  void disposeForm() {
    fullNameController.dispose();
    phoneNumberController.dispose();
    occupationNotifier.dispose();
    addressController.dispose();
    groupNameController.dispose();
    instructorNameController.dispose();
  }

  // state
  NotifierState<void> state = NotifierState();
  NotifierState<void> updateProfileState = NotifierState();
  NotifierState<void> updateProfileImageState = NotifierState();
  NotifierState<void> logoutState = NotifierState();
  NotifierState<void> deleteAccountState = NotifierState();

  // data
  UserData? userData;

  final AuthRepository repository;

  AuthNotifier({required this.repository});

  bool isAdmin() {
    return userData?.isAdmin ?? false;
  }

  void setUser(UserData userData) {
    this.userData = userData;
  }

  void getUserFromLocal() {
    state.setLoading();
    notifyListeners();

    final result = repository.getFromLocal();
    if (result == null) {
      // user not exist in cache
      state.setError();
      notifyListeners();
    } else {
      userData = result;
      state.setSuccess();
      notifyListeners();
    }
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;
    updateProfileState.setLoading();
    notifyListeners();

    final result = await repository.updateProfile(
      userId: userData!.id,
      fullName: fullNameController.text,
      phoneNumber: phoneNumberController.text,
      occupation: occupationNotifier.value,
      address: addressController.text,
      groupName: groupNameController.text,
      instructorName: instructorNameController.text,
    );

    result.fold(
      (failure) {
        updateProfileState.setError(failure: failure);
        notifyListeners();
      },
      (data) async {
        userData = data;
        await repository.cacheToLocal(userData: userData!);
        updateProfileState.setSuccess();
        notifyListeners();
        Future.delayed(
          const Duration(milliseconds: 500),
          () {
            updateProfileState.reset();
          },
        );
      },
    );
  }

  Future<void> logout() async {
    logoutState.setLoading();
    notifyListeners();

    final result = await repository.logOut();
    result.fold(
      (failure) {
        logoutState.setError(failure: failure);
        notifyListeners();
      },
      (data) {
        logoutState.setSuccess();
        notifyListeners();
        Future.delayed(
          const Duration(milliseconds: 500),
          () {
            logoutState.reset();
          },
        );
      },
    );
  }

  Future<void> deleteAccount(String pin) async {
    deleteAccountState.setLoading();
    notifyListeners();

    final result = await repository.deleteAccount(
      userId: userData!.id,
      pin: pin,
    );
    result.fold(
      (failure) {
        deleteAccountState.setError(failure: failure);
        notifyListeners();
      },
      (data) {
        deleteAccountState.setSuccess();
        notifyListeners();
      },
    );
  }
}
