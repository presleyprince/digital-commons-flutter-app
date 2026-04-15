import 'package:digital_shores/app/data/models/finance_history_model.dart';
import 'package:digital_shores/app/data/models/finance_log_model.dart';

class AddFinanceLogParameter {
  final int amount;
  final String description;
  final int date;
  final int category;

  AddFinanceLogParameter({
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
  });
}

class UpdateFinanceLogParameter {
  final String userId;
  final String id;
  final String description;
  final int amount;
  final int date;
  final int category;

  UpdateFinanceLogParameter({
    required this.userId,
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });
}

class SyncFinanceLogsParameter {
  final FinanceHistoryModel financeHistory;
  final Map<String, FinanceLogModel> financeLogs;

  SyncFinanceLogsParameter({
    required this.financeHistory,
    required this.financeLogs,
  });
}

class DeleteFinanceLogParameter {
  final String id;

  DeleteFinanceLogParameter({
    required this.id,
  });
}

class GetFinanceLogsParameter {
  final String userId;

  GetFinanceLogsParameter({
    required this.userId,
  });
}

class AddFinanceLogToLocalParameter {
  final int amount;
  final String description;
  final int date;
  final int category;

  AddFinanceLogToLocalParameter({
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
  });
}

class UpdateFinanceLogFromLocalParameter {
  final String id;
  final int amount;
  final String description;
  final int date;
  final int category;

  UpdateFinanceLogFromLocalParameter({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
  });
}

class DeleteFinanceLogFromLocalParameter {
  final String id;

  DeleteFinanceLogFromLocalParameter({
    required this.id,
  });
}

class CacheFinanceLogsToLocalParameter {
  final List<FinanceLogModel> financeLogs;

  CacheFinanceLogsToLocalParameter({
    required this.financeLogs,
  });
}
