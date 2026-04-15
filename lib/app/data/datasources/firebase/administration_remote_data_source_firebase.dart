import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_shores/app/data/datasources/abstract/menu/administration/administration_remote_data_source.dart';
import 'package:digital_shores/app/data/models/administration_document_image_model.dart';
import 'package:digital_shores/app/data/models/administration_document_model.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/parameters/administration_parameters.dart';
import 'package:digital_shores/core/utils/local_image_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AdministrationRemoteDataSourceFirebase extends AdministrationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage;

  AdministrationRemoteDataSourceFirebase(
      {required FirebaseFirestore firestore, required FirebaseStorage firebaseStorage})
      : _firestore = firestore,
        _firebaseStorage = firebaseStorage;

  final String administrationDocumentsCollection = 'administration_documents';
  final String administrationImagesFolder = 'administration_images';

  @override
  Future<List<AdministrationDocumentModel>> getDocuments(GetDocumentsParameter params) async {
    final List<AdministrationDocumentModel> documents = [];
    final querySnapshot = await _firestore
        .collection(administrationDocumentsCollection)
        .where('user_id', isEqualTo: params.userId)
        .get()
        .timeout(
      kTimeoutDuration,
      onTimeout: () {
        throw kTimeoutException;
      },
    );

    // get all images
    for (final doc in querySnapshot.docs) {
      final imagesQuerySnapshot = await _firestore
          .collection(administrationImagesFolder)
          .where('document_id', isEqualTo: doc.id)
          .get()
          .timeout(
        kTimeoutDuration,
        onTimeout: () {
          throw kTimeoutException;
        },
      );

      final Map<String, dynamic> documentJson = Map.from(doc.data());

      documentJson['images'] = imagesQuerySnapshot.docs.map((image) => image.data()).toList();

      final document = AdministrationDocumentModel.fromJson(documentJson);

      documents.add(document);
    }

    return documents;
  }

  @override
  Future<List<AdministrationDocumentModel>> syncDocuments(SyncDocumentsParameter params) async {
    // for all documents, check if all of the images are deleted or not yet synced.
    // then check if the document are deleted or synced

    final List<AdministrationDocumentModel> newDocuments = [];

    final batch = _firestore.batch();

    for (final document in params.documents) {
      final List<AdministrationDocumentImageModel> newImages = [];

      // for all images, check if the image is deleted or not yet synced
      for (final image in document.images) {
        // delete the image in storage and firestore
        if (image.isDeleted == 1) {
          // if the image is synced, delete the image in storage and firestore. else, do nothing
          try {
            final imageRef = _firebaseStorage.ref(
                'documents/${document.userId}/${document.customType ?? DocumentType.values[document.type].label}/${image.id}.jpg');

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

          await _firestore.collection(administrationImagesFolder).doc(image.id).delete().timeout(
            kTimeoutDuration,
            onTimeout: () {
              throw kTimeoutException;
            },
          );

          final newImage = image.copyWith(
            cloudUrl: null,
            isSynced: 1,
          );

          newImages.add(newImage);
        }

        // upload image that are not yet synced and create a new document in firestore
        else if (image.isSynced == 0) {
          final imageRef = _firebaseStorage.ref().child(
              'documents/${document.userId}/${document.customType ?? DocumentType.values[document.type].label}/${image.id}.jpg');
          final file = LocalImageHandler.getFileFromLocalPath(image.localPath!);
          await imageRef.putData(
            await file.readAsBytes(),
            SettableMetadata(contentType: 'image/jpeg'),
          );

          final cloudUrl = await imageRef.getDownloadURL();

          final newImage = image.copyWith(
            cloudUrl: cloudUrl,
            isSynced: 1,
          );

          await _firestore
              .collection(administrationImagesFolder)
              .doc(image.id)
              .set(newImage.toJson());

          // add the new image to the list
          newImages.add(newImage);
        } else {
          // add the image to the list
          newImages.add(image);
        }
      }

      // check if the document is deleted or not yet synced
      if (document.isDeleted == 1) {
        final docRef = _firestore.collection(administrationDocumentsCollection).doc(document.id);

        await docRef.delete().timeout(
          kTimeoutDuration,
          onTimeout: () {
            throw kTimeoutException;
          },
        );

        final newDocument = document.copyWith(
          images: newImages,
          isSynced: 1,
        );

        // add the new document to the list
        newDocuments.add(newDocument);
      } else if (document.isSynced == 0) {
        final docRef = _firestore.collection(administrationDocumentsCollection).doc(document.id);

        final newDocument = document.copyWith(
          images: newImages,
          isSynced: 1,
        );

        batch.set(docRef, newDocument.toJson());
        // add the new document to the list
        newDocuments.add(newDocument);
      } else {
        // add the document to the list
        newDocuments.add(document.copyWith(
          images: newImages,
        ));
      }
    }

    await batch.commit().timeout(
      kTimeoutDuration,
      onTimeout: () {
        throw kTimeoutException;
      },
    );

    return newDocuments;
  }
}
