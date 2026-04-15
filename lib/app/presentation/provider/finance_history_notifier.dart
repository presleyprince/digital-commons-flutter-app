import 'package:digital_shores/app/domain/entities/finance_log.dart';
import 'package:digital_shores/app/domain/repositories/finance_repository.dart';
import 'package:digital_shores/app/presentation/provider/i_finance_notifier.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/currency_format.dart';
import 'package:digital_shores/core/utils/notifier_state.dart';
import 'package:flutter/material.dart';

class FinanceHistoryNotifier extends ChangeNotifier implements IFinanceNotifier {
  // form
  late ValueNotifier<FinanceLogCategory?> categoryFilterController;
  late ValueNotifier<DateTime?> monthFilterController;
  late ValueNotifier<FinanceHistoryRangeType> rangeTypeController;
  int? incomeTotal;
  int? expenseTotal;
  int? loanTotal;

  // edit form
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
  late String id;
  FinanceLog? selectedData;

  // state
  NotifierState<void> addDataState = NotifierState();
  @override
  NotifierState<void> deleteDataState = NotifierState();

  // data
  Map<String, FinanceLog> financeMap = {};
  ValueNotifier<List<FinanceLog>> financeList = ValueNotifier([]);

  final FinanceRepository repository;

  FinanceHistoryNotifier({required this.repository});

  void initForm(String dataId) {
    // final data = financeMap[id]!;
    id = dataId;
    final data = financeList.value.firstWhere((element) => element.id == id);
    selectedData = data;
    descriptionController = TextEditingController(text: data.description);
    dateController = ValueNotifier(data.date);
    amountController = TextEditingController(text: data.amount.toString());
    financeCategoryController = ValueNotifier(data.category);
    formKey = GlobalKey<FormState>();
  }

  void resetForm() {
    descriptionController.dispose();
    dateController.dispose();
    amountController.dispose();
    financeCategoryController.dispose();
    selectedData = null;
    formKey.currentState?.reset();
  }

  @override
  void addData() async {
    if (formKey.currentState!.validate()) {
      addDataState.setLoading();
      notifyListeners();

      // late Either<Failure, FinanceLog> result;

      // user want to edit data
      final result = await repository.updateFinanceLogFromLocal(
        id: id,
        description: descriptionController.text,
        amount: CurrencyFormat.getCurrencyValue(amountController.text),
        category: financeCategoryController.value,
        date: dateController.value!,
      );

      result.fold(
        (failure) {
          addDataState.setError(failure: failure);
          notifyListeners();
        },
        (data) async {
          // financeMap[data.id] = data;
          financeList.value = financeList.value.map((e) {
            if (e.id == data.id) {
              return data;
            }
            return e;
          }).toList();
          switch (rangeTypeController.value) {
            case FinanceHistoryRangeType.today:
              setFilterToToday();
              break;
            case FinanceHistoryRangeType.thisWeek:
              setFilterToThisWeek();
              break;
            case FinanceHistoryRangeType.thisMonth:
              setFilterToThisMonth();
              break;
            case FinanceHistoryRangeType.customMonth:
              setFilterCustomMonth();
              break;
          }
          addDataState.setSuccess();
          notifyListeners();
        },
      );

      await Future.delayed(const Duration(seconds: 1), () => addDataState.reset());
    }
  }

  @override
  void setSelectedData(FinanceLog data) {}

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
        // financeMap.remove(data.id);
        financeList.value = financeList.value.where((element) => element.id != data.id).toList();
        switch (rangeTypeController.value) {
          case FinanceHistoryRangeType.today:
            setFilterToToday();
            break;
          case FinanceHistoryRangeType.thisWeek:
            setFilterToThisWeek();
            break;
          case FinanceHistoryRangeType.thisMonth:
            setFilterToThisMonth();
            break;
          case FinanceHistoryRangeType.customMonth:
            setFilterCustomMonth();
            break;
        }
        deleteDataState.setSuccess();
        notifyListeners();
      },
    );
    Future.delayed(const Duration(seconds: 1), () => deleteDataState.reset());
  }

  @override
  void setCategory(FinanceLogCategory category) {
    financeCategoryController.value = category;
  }

  void init() {
    incomeTotal = 0;
    expenseTotal = 0;
    loanTotal = 0;
    financeList = ValueNotifier([]);
    categoryFilterController = ValueNotifier(null);
    monthFilterController = ValueNotifier(null);
    rangeTypeController = ValueNotifier(FinanceHistoryRangeType.today);
    monthFilterController.addListener(() {
      if (rangeTypeController.value == FinanceHistoryRangeType.customMonth) {
        setFilterCustomMonth();
      }
    });
    rangeTypeController.addListener(() {
      switch (rangeTypeController.value) {
        case FinanceHistoryRangeType.today:
          setFilterToToday();
          break;
        case FinanceHistoryRangeType.thisWeek:
          setFilterToThisWeek();
          break;
        case FinanceHistoryRangeType.thisMonth:
          setFilterToThisMonth();
          break;
        case FinanceHistoryRangeType.customMonth:
          setFilterCustomMonth();
          break;
      }
    });
    categoryFilterController.addListener(() {
      switch (rangeTypeController.value) {
        case FinanceHistoryRangeType.today:
          setFilterToToday();
          break;
        case FinanceHistoryRangeType.thisWeek:
          setFilterToThisWeek();
          break;
        case FinanceHistoryRangeType.thisMonth:
          setFilterToThisMonth();
          break;
        case FinanceHistoryRangeType.customMonth:
          setFilterCustomMonth();
          break;
      }
    });
  }

  void reset() {
    incomeTotal = null;
    expenseTotal = null;
    loanTotal = null;
    categoryFilterController = ValueNotifier(null);
    monthFilterController = ValueNotifier(null);
    rangeTypeController = ValueNotifier(FinanceHistoryRangeType.today);
    financeList.dispose();
  }

  Future<void> setFilterToToday() async {
    final now = DateTime.now();
    await filterData(
      startDate: DateTime(now.year, now.month, now.day),
      endDate: DateTime(now.year, now.month, now.day + 1),
      category: categoryFilterController.value,
    );
  }

  Future<void> setFilterToThisWeek() async {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
      0,
      0,
      0,
    );

    final endOfWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1) + 6,
      23,
      59,
      59,
    );

    await filterData(
      startDate: startOfWeek,
      endDate: endOfWeek,
      category: categoryFilterController.value,
    );
  }

  Future<void> setFilterToThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    await filterData(
      startDate: startOfMonth,
      endDate: endOfMonth,
      category: categoryFilterController.value,
    );
  }

  Future<void> setFilterCustomMonth() async {
    final endDate = DateTime(
      monthFilterController.value!.year,
      monthFilterController.value!.month + 1,
      1,
    );
    await filterData(
      startDate: monthFilterController.value,
      endDate: endDate,
      category: categoryFilterController.value,
    );
  }

  Future<void> filterData({
    DateTime? startDate,
    DateTime? endDate,
    FinanceLogCategory? category,
  }) async {
    final filtered = await getLogsList(
      startDate: startDate,
      endDate: endDate,
      category: category,
    );
    financeList.value = filtered;
  }

  Future<List<FinanceLog>> getLogsList({
    bool sortByDate = true,
    DateTime? startDate,
    DateTime? endDate,
    FinanceLogCategory? category,
  }) async {
    // Filter and convert to list only when needed
    final data = await repository.getFinanceLogsFromLocal();
    final filtered = data.where((log) {
      final dateMatches = (startDate == null || log.date.isAfter(startDate)) &&
          (endDate == null || log.date.isBefore(endDate));
      final categoryMatches = category == null || log.category == category;
      return dateMatches && categoryMatches;
    }).toList();

    // calculate total
    incomeTotal = filtered
        .where((element) => element.category == FinanceLogCategory.income)
        .map((e) => e.amount)
        .fold(0, (prev, amount) => prev! + amount);
    expenseTotal = filtered
        .where((element) => element.category == FinanceLogCategory.expense)
        .map((e) => e.amount)
        .fold(0, (prev, amount) => prev! + amount);
    loanTotal = filtered
        .where((element) => element.category == FinanceLogCategory.loan)
        .map((e) => e.amount)
        .fold(0, (prev, amount) => prev! + amount);
    // Sort only if needed
    if (sortByDate) {
      filtered.sort((a, b) => b.date.compareTo(a.date));
    }

    return filtered;
  }
}
