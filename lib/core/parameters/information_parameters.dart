import 'dart:io';

import 'package:digital_shores/app/data/models/information_model.dart';

class GetInformationsParameter {
  final int? lastSync;

  GetInformationsParameter({required this.lastSync});
}

class GetInformationByIdParameter {
  final String id;

  GetInformationByIdParameter({required this.id});
}

class AddInformationParameter {
  final String title;
  final File image;
  final String content;
  final String authorId;
  final String authorName;
  final int category;

  AddInformationParameter({
    required this.title,
    required this.image,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.category,
  });
}

class UpdateInformationParameter {
  final String id;
  final String? title;
  final File? image;
  final String? content;
  final String? authorId;
  final int? category;
  final InformationModel oldInformation;

  UpdateInformationParameter({
    required this.id,
    required this.title,
    required this.image,
    required this.content,
    required this.authorId,
    required this.category,
    required this.oldInformation,
  });
}

class DeleteInformationParameter {
  final InformationModel information;

  DeleteInformationParameter({required this.information});
}

// local
class DeleteInformationFromLocalParameter {
  final String id;

  DeleteInformationFromLocalParameter({required this.id});
}

class CacheInformationsToLocalParameter {
  final List<InformationModel> informations;

  CacheInformationsToLocalParameter({required this.informations});
}

class UpdateInformationsFromLocalParameter {
  final List<InformationModel> informations;

  UpdateInformationsFromLocalParameter({required this.informations});
}

class SyncInformationsToLocalParameter {
  final List<InformationModel> informations;

  SyncInformationsToLocalParameter({required this.informations});
}
