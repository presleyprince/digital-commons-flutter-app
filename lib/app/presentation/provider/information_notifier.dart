import 'package:digital_shores/app/domain/entities/information.dart';
import 'package:digital_shores/app/domain/repositories/information_repository.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/notifier_state.dart';
import 'package:flutter/material.dart';

class InformationNotifier extends ChangeNotifier {
  // state
  NotifierState<void> fetchDataState = NotifierState();
  NotifierState<void> syncDataState = NotifierState();
  NotifierState<void> deleteDataState = NotifierState();

  // data
  final ValueNotifier<List<Information>> informations = ValueNotifier([]);
  Information? informationDetail;

  // filter
  ValueNotifier<InformationCategory?> categoryFilterController = ValueNotifier(null);

  final InformationRepository _repository;

  InformationNotifier({required InformationRepository repository}) : _repository = repository;

  void init() {
    categoryFilterController.addListener(updateFilter);
  }

  void updateFilter() {
    notifyListeners();
  }

  void setInformationDetail(Information information) {
    informationDetail = information;
  }

  void clearInformationDetail() {
    informationDetail = null;
  }

  void clearInformationsFromLocal() async {
    await _repository.clearInformationsFromLocal();
    informations.value = [];
  }

  List<Information> getHomeLatestInformations(int count) {
    if (informations.value.length < count) {
      return informations.value;
    }

    return informations.value.sublist(0, count);
  }

  List<Information> getInformations({int? count}) {
    return informations.value
        .where((e) =>
            categoryFilterController.value == null || e.category == categoryFilterController.value)
        .toList();
  }

  Future<void> fetchData() async {
  fetchDataState.setLoading();
  notifyListeners();
  final result = await _repository.getInformations();
  final allInformations = await _repository.getInformationsFromLocal();
  informations.value = allInformations;

  result.fold(
    (failure) {
      //works offline instea of error message
      if (allInformations.isEmpty) {
        fetchDataState.setError(failure: failure);
      } else {
        fetchDataState.setSuccess();
      }
    },
    (_) => fetchDataState.setSuccess(),
  );
  notifyListeners();
}

  Future<void> getDataFromLocal() async {
    fetchDataState.setLoading();
    Future.microtask(() => notifyListeners());

    final data = await _repository.getInformationsFromLocal();
    informations.value = data;

    fetchDataState.setSuccess();
    notifyListeners();
  }

  Future<void> syncData() async {
    syncDataState.setLoading();
    notifyListeners();

    final result = await _repository.syncInformations();
    result.fold(
      (failure) => syncDataState.setError(failure: failure),
      (data) {
        informations.value = data;
        syncDataState.setSuccess();
      },
    );
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () => syncDataState.reset());
  }

  void addData(Information information) {
    informations.value = [information, ...informations.value];
    Future.microtask(() => notifyListeners());
  }

  void updateData(Information information) {
    informations.value =
        informations.value.map((e) => e.id == information.id ? information : e).toList();
    Future.microtask(() => notifyListeners());
  }

  void deleteData(String id) {
    informations.value = informations.value.where((e) => e.id != id).toList();
    Future.microtask(() => notifyListeners());
  }
}
