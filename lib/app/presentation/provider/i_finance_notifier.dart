import 'package:digital_shores/app/domain/entities/finance_log.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/notifier_state.dart';
import 'package:flutter/material.dart';

abstract class IFinanceNotifier extends ChangeNotifier {
  GlobalKey<FormState> get formKey;
  ValueNotifier<FinanceLogCategory> get financeCategoryController;
  ValueNotifier<DateTime?> get dateController;
  TextEditingController get descriptionController;
  TextEditingController get amountController;

  NotifierState<void> get deleteDataState;

  void setCategory(FinanceLogCategory category);
  void addData();
  void deleteData(FinanceLog data);
  void setSelectedData(FinanceLog data);
}
