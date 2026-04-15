import 'package:dartz/dartz.dart';
import 'package:digital_shores/app/domain/entities/finance_log.dart';
import 'package:digital_shores/app/domain/repositories/finance_repository.dart';
import 'package:digital_shores/app/presentation/provider/i_finance_notifier.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/failure.dart';
import 'package:digital_shores/core/utils/currency_format.dart';
import 'package:digital_shores/core/utils/notifier_state.dart';
import 'package:flutter/material.dart';

class FinanceNotifier extends ChangeNotifier implements IFinanceNotifier {
  // state
  NotifierState<void> addDataState = NotifierState();
  @override
  NotifierState<void> deleteDataState = NotifierState();
  NotifierState<void> fetchDataState = NotifierState();
  NotifierState<void> syncDataState = NotifierState();

  // form
  @override
  late ValueNotifier<FinanceLogCategory> financeCategoryController;
  @override
  late ValueNotifier<DateTime?> dateController;
  @override
  late TextEditingController descriptionController;
  @override
  late TextEditingController amountController;
  @override
  late GlobalKey<FormState> formKey;
  ValueNotifier<FinanceLog?> selectedData = ValueNotifier(null);

  // data
  Map<String, FinanceLog> financeMap = {};
  ValueNotifier<List<FinanceLog>> financeList = ValueNotifier([]);

  final FinanceRepository repository;

  FinanceNotifier({required this.repository});

  void initForm(FinanceLog? data, {bool newForm = true}) {
    selectedData.value = data;
    if (newForm) addDataState.reset();
    descriptionController = TextEditingController(text: selectedData.value?.description);
    dateController = ValueNotifier(selectedData.value?.date);
    amountController = TextEditingController(text: selectedData.value?.amount.toString());
    financeCategoryController =
        ValueNotifier(selectedData.value?.category ?? FinanceLogCategory.expense);
    formKey = GlobalKey<FormState>();
  }

  void clearForm() {
    descriptionController.clear();
    dateController.value = null;
    amountController.clear();
    financeCategoryController.value = FinanceLogCategory.expense;
  }

  void reset() {
    selectedData.value = null;
    descriptionController.dispose();
    dateController = ValueNotifier(null);
    amountController.dispose();
    financeCategoryController.dispose();
    formKey.currentState?.reset();
  }

  void setDate(DateTime date) {
    dateController.value = date;
    notifyListeners();
  }

  @override
  void setCategory(FinanceLogCategory category) {
    financeCategoryController.value = category;
    notifyListeners();
  }

  Future<void> fetchData(String userId) async {
    fetchDataState.setLoading();
    notifyListeners();

    final result = await repository.getFinanceLogs(userId: userId);

    result.fold(
      (failure) {
        fetchDataState.setError(failure: failure);
        notifyListeners();
      },
      (data) async {
        financeMap = {for (final item in data) item.id: item};
        await repository.cacheFinanceLogsToLocal(data);
        fetchDataState.setSuccess();
        notifyListeners();
      },
    );
  }

  Future<List<FinanceLog>> getLogsList({
    bool sortByDate = true,
    DateTime? startDate,
    DateTime? endDate,
    FinanceLogCategory? category,
  }) async {
    // Filter and convert to list only when needed
    // print(financeMap.values.first.date);
    final data = await repository.getFinanceLogsFromLocal();
    var filtered = data.where((log) {
      final dateMatches = (startDate == null || log.date.isAfter(startDate)) &&
          (endDate == null || log.date.isBefore(endDate));
      final categoryMatches = category == null || log.category == category;
      return dateMatches && categoryMatches;
    }).toList();

    // Sort only if needed
    if (sortByDate) {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    }

    return filtered;
  }

  Future<void> getTodayData() async {
    final today = DateTime.now();
    financeList.value = await getLogsList(
      startDate: DateTime(today.year, today.month, today.day),
      endDate: DateTime(today.year, today.month, today.day, 23, 59, 59),
    );
    Future.microtask(() => notifyListeners());
  }

  bool dataEmpty() {
    return financeMap.isEmpty;
  }

  Future<void> getDataFromLocal() async {
    final data = await repository.getFinanceLogsFromLocal();
    financeMap = {for (final item in data) item.id: item};
  }

  void resetDelete() {
    deleteDataState.reset();
  }

  void deleteDataList() {
    financeMap = {};
  }

  void clearSelectedData() {
    selectedData.value = null;
    initForm(null, newForm: false);
  }

  @override
  void setSelectedData(FinanceLog data) {
    selectedData.value = data;
    initForm(data, newForm: false);
  }

  @override
  Future<void> deleteData(FinanceLog finance) async {
    deleteDataState.setLoading();
    notifyListeners();

    final result = await repository.deleteFinanceLogFromLocal(id: finance.id);

    result.fold(
      (failure) {
        deleteDataState.setError(failure: failure);
        notifyListeners();
      },
      (data) async {
        financeMap.remove(data.id);
        getTodayData();
        deleteDataState.setSuccess();
        notifyListeners();
        await Future.delayed(const Duration(seconds: 1), () => deleteDataState.reset());
      },
    );
  }

  @override
  Future<void> addData() async {
    if (formKey.currentState!.validate()) {
      addDataState.setLoading();
      notifyListeners();

      late Either<Failure, FinanceLog> result;

      // user want to edit data
      if (selectedData.value != null) {
        result = await repository.updateFinanceLogFromLocal(
          id: selectedData.value!.id,
          description: descriptionController.text,
          amount: CurrencyFormat.getCurrencyValue(amountController.text),
          category: financeCategoryController.value,
          date: dateController.value!,
        );
      } else {
        result = await repository.addFinanceLogToLocal(
          description: descriptionController.text,
          category: financeCategoryController.value,
          amount: CurrencyFormat.getCurrencyValue(amountController.text),
          date: dateController.value!,
        );
      }

      result.fold(
        (failure) {
          addDataState.setError(failure: failure);
          notifyListeners();
        },
        (data) async {
          financeMap[data.id] = data;
          getTodayData();
          addDataState.setSuccess();
          notifyListeners();

          // if add new data success, clear the form
          if (selectedData.value == null) {
            clearForm();
          } else {
            clearSelectedData();
          }
        },
      );

      await Future.delayed(const Duration(seconds: 1), () => addDataState.reset());
    }
  }

  void clearFinanceLogsFromLocal() async {
    await repository.clearFinanceLogsFromLocal();
  }

  Future<void> syncFinanceLogs() async {
    syncDataState.setLoading();
    notifyListeners();

    final result = await repository.syncFinanceLogs();

    result.fold(
      (failure) {
        syncDataState.setError(failure: failure);
        notifyListeners();
      },
      (_) async {
        syncDataState.setSuccess();
        notifyListeners();
      },
    );

    await Future.delayed(const Duration(seconds: 1), () => syncDataState.reset());
  }
}
