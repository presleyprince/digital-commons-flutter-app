import 'package:digital_shores/app/data/models/information_model.dart';
import 'package:digital_shores/core/parameters/information_parameters.dart';

abstract class InformationLocalDataSource {
  Future<List<InformationModel>> getInformationsFromLocal();
  Future<void> deleteInformationFromLocal(DeleteInformationFromLocalParameter params);
  Future<void> cacheInformationsToLocal(CacheInformationsToLocalParameter params);
  Future<void> clearInformationsFromLocal();
  Future<List<InformationModel>> updateInformationsFromLocal(
      UpdateInformationsFromLocalParameter params);
  Future<List<InformationModel>> syncInformationsToLocal(SyncInformationsToLocalParameter params);
  int getInformationLastSync();
  Future<void> updateInformationLastSync();
}
