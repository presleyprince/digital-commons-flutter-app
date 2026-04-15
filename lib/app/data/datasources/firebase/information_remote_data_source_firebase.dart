import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/information/information_remote_data_source.dart';
import 'package:digital_shores/app/data/models/information_model.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/parameters/information_parameters.dart';
import 'package:firebase_storage/firebase_storage.dart';

class InformationRemoteDataSourceFirebase extends InformationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage;

  InformationRemoteDataSourceFirebase(
      {required FirebaseFirestore firestore, required FirebaseStorage firebaseStorage})
      : _firestore = firestore,
        _firebaseStorage = firebaseStorage;

  final String informationsCollection = 'informations';

  @override
  Future<InformationModel> addInformation(AddInformationParameter params) async {
    final docRef = _firestore.collection(informationsCollection).doc();

    // upload image to firebase storage
    final imageRef = _firebaseStorage.ref().child('informations/${docRef.id}.jpg');
    await imageRef.putFile(params.image);
    final imageUrl = await imageRef.getDownloadURL();

    final createdAt = DateTime.now().toUtc().millisecondsSinceEpoch;

    final information = InformationModel(
      id: docRef.id,
      title: params.title,
      content: params.content,
      author: params.authorName,
      category: params.category,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    // create json and insert authorId
    final json = information.toJson();
    json['author_id'] = params.authorId;

    await docRef.set(json);

    return information;
  }

  @override
  Future<InformationModel> deleteInformation(DeleteInformationParameter params) async {
    final information = params.information;

    // delete image on firebase storage

    try {
      final imageRef = _firebaseStorage.ref('informations/${information.id}.jpg');

      // Check if file exists by attempting to get metadata
      await imageRef.getMetadata().timeout(
        kTimeoutDuration,
        onTimeout: () {
          throw kTimeoutException;
        },
      );

      // If we reach here, file exists, so delete it
      await imageRef.delete().timeout(
        kTimeoutDuration,
        onTimeout: () {
          throw kTimeoutException;
        },
      );
    } catch (e) {
      // If error is "object-not-found", just skip it
      if (e is FirebaseException && e.code == 'object-not-found') {
        // File doesn't exist, silently continue
        // return;
      }
      // For other errors, rethrow them
      // rethrow;
    }

    // the document is not deleted because user could sync the doc and see that
    // the doc is_deleted is true then will be deleted from their local
    final deletedAt = DateTime.now().toUtc().millisecondsSinceEpoch;
    final docRef = _firestore.collection(informationsCollection).doc(information.id);
    await docRef.update({
      'is_deleted': true,
      'deleted_at': deletedAt,
    });

    return information;
  }

  @override
  Future<InformationModel> getInformationById(GetInformationByIdParameter params) async {
    final id = params.id;

    final doc = await _firestore.collection(informationsCollection).doc(id).get();

    return InformationModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<InformationModel>> getInformations(GetInformationsParameter params) async {
    // if last sync is empty, get all informations. else, only get informations where its updated at is bigger than last sync
    late Query<Map<String, dynamic>> query;

    if (params.lastSync != null) {
      query = _firestore
          .collection(informationsCollection)
          .where('updated_at', isGreaterThan: params.lastSync)
          .where('is_deleted', isEqualTo: 0)
          .orderBy(
            'updated_at',
            descending: true,
          );
    } else {
      query = _firestore.collection(informationsCollection).orderBy(
            'updated_at',
            descending: true,
          );
    }

    final docs = await query.get();

    final informations = docs.docs.map((e) => InformationModel.fromJson(e.data())).toList();

    return informations;
  }

  @override
  Future<InformationModel> updateInformation(UpdateInformationParameter params) async {
    // if image is not null, upload the new image by overwrite the old image and get the link
    // upload the new url to the updated document

    String? imageUrl;
    if (params.image != null) {
      final imageRef = _firebaseStorage.ref().child('informations/${params.id}.jpg');
      await imageRef.putFile(params.image!);
      imageUrl = await imageRef.getDownloadURL();
    }

    final docRef = _firestore.collection(informationsCollection).doc(params.id);

    final updatedAt = DateTime.now().toUtc().millisecondsSinceEpoch;

    final newInformation = params.oldInformation.copyWith(
      title: params.title,
      category: params.category,
      content: params.content,
      imageUrl: imageUrl,
      updatedAt: updatedAt,
    );

    await docRef.update(newInformation.toJson());

    return newInformation;
  }
}
