import 'package:digital_shores/app/data/models/information_model.dart';
import 'package:digital_shores/core/parameters/information_parameters.dart';

abstract class InformationRemoteDataSource {
  Future<List<InformationModel>> getInformations(GetInformationsParameter params);
  Future<InformationModel> getInformationById(GetInformationByIdParameter params);
  Future<InformationModel> addInformation(AddInformationParameter params);
  Future<InformationModel> updateInformation(UpdateInformationParameter params);
  Future<InformationModel> deleteInformation(DeleteInformationParameter params);
}
