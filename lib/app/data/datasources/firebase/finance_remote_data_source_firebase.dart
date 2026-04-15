import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/finance/finance_remote_data_source.dart';
import 'package:digital_shores/app/data/models/finance_log_model.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/parameters/finance_parameters.dart';

class FinanceRemoteDataSourceFirebase extends FinanceRemoteDataSource {
  final FirebaseFirestore firestore;

  final String financeLogsCollection = 'finance_logs';

  FinanceRemoteDataSourceFirebase({required this.firestore});

  @override
  Future<FinanceLogModel> addFinanceLog(AddFinanceLogParameter parameter) async {
    final docRef = firestore.collection(financeLogsCollection).doc();

    final financeLog = FinanceLogModel(
      id: docRef.id,
      amount: parameter.amount,
      description: parameter.description,
      date: parameter.date,
      category: parameter.category,
    );

    await docRef.set(financeLog.toJson()).timeout(
      kTimeoutDuration,
      onTimeout: () {
        throw kTimeoutException;
      },
    );

    return financeLog;
  }

  @override
  Future<FinanceLogModel> deleteFinanceLog(DeleteFinanceLogParameter parameter) async {
    final docRef = firestore.collection(financeLogsCollection).doc(parameter.id);

    // get the document
    final doc = await docRef.get();
    await docRef.delete().timeout(
      kTimeoutDuration,
      onTimeout: () {
        throw kTimeoutException;
      },
    );
    // return the document as a ActivityModel
    return FinanceLogModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<FinanceLogModel>> getFinanceLogs(GetFinanceLogsParameter parameter) async {
    final querySnapshot = await firestore
        .collection(financeLogsCollection)
        .where('user_id', isEqualTo: parameter.userId)
        .get()
        .timeout(
      kTimeoutDuration,
      onTimeout: () {
        throw kTimeoutException;
      },
    );
    return querySnapshot.docs.map((doc) => FinanceLogModel.fromJson(doc.data())).toList();
  }

  @override
  Future<void> syncFinanceLogs(SyncFinanceLogsParameter parameter) async {
    // use batch to overwrite below operation

    for (final history in parameter.financeHistory.history.entries) {
      final financeLogDocRef = firestore.collection(financeLogsCollection).doc(history.key);

      if (history.value == 'created') {
        final financeLog = parameter.financeLogs[history.key]!;
        await financeLogDocRef.set(financeLog.toJson()).timeout(
          kTimeoutDuration,
          onTimeout: () {
            throw kTimeoutException;
          },
        );
      } else if (history.value == 'deleted') {
        final doc = await financeLogDocRef.get();
        if (doc.exists) {
          await financeLogDocRef.delete().timeout(
            kTimeoutDuration,
            onTimeout: () {
              throw kTimeoutException;
            },
          );
        }
      } else {
        throw Exception('Invalid history value');
      }
    }

    // await firestore.runTransaction((transaction) async {
    //   for (final history in parameter.financeHistory.history.entries) {
    //     final financeLogDocRef = firestore.collection(financeLogsCollection).doc(history.key);

    //     if (history.value == 'created') {
    //       final financeLog = parameter.financeLogs[history.key]!;
    //       transaction.set(financeLogDocRef, financeLog.toJson());
    //     } else if (history.value == 'deleted') {
    //       final doc = await transaction.get(financeLogDocRef);
    //       if (doc.exists) {
    //         transaction.delete(financeLogDocRef);
    //       }
    //     } else {
    //       throw Exception('Invalid history value');
    //     }
    //   }
    // });
  }

  @override
  Future<FinanceLogModel> updateFinanceLog(UpdateFinanceLogParameter parameter) async {
    final docRef = firestore.collection(financeLogsCollection).doc(parameter.id);

    final activity = FinanceLogModel(
      id: parameter.id,
      userId: parameter.userId,
      amount: parameter.amount,
      date: parameter.date,
      description: parameter.description,
      category: parameter.category,
    );

    await docRef.update(activity.toJson()).timeout(
      kTimeoutDuration,
      onTimeout: () {
        throw kTimeoutException;
      },
    );

    return activity;
  }
}
